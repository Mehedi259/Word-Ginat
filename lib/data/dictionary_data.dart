import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/word_model.dart';

class DictionaryData {
  static List<WordModel>? _kidsWords;
  static List<WordModel>? _standardWords;
  static bool _isLoadingKids = false;
  static bool _isLoadingStandard = false;

  // Cached constants for lightning-fast UI rendering
  static const int kidsWordsCount = 123446;
  static const int standardWordsCount = 146722;
  static const int totalWordsCount = 270168;
  static const int visualWordsCount = 2452;

  // Load Kids Dictionary on-demand
  static Future<void> loadKidsDictionary() async {
    if (_kidsWords != null || _isLoadingKids) return;
    _isLoadingKids = true;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/Kids_Dictionary_Final_Refined.json',
      );
      final List<dynamic> data = json.decode(jsonString);
      _kidsWords = data
          .map((item) => WordModel.fromJson(item, level: DifficultyLevel.easy))
          .toList();
    } catch (e, stack) {
      debugPrint('Error loading Kids dictionary: $e\n$stack');
      _kidsWords ??= _getSampleKidsWords();
    } finally {
      _isLoadingKids = false;
    }
  }

  // Load Standard Dictionary on-demand
  static Future<void> loadStandardDictionary() async {
    if (_standardWords != null || _isLoadingStandard) return;
    _isLoadingStandard = true;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/Standard_Dictionary_Final_Refined.json',
      );
      final List<dynamic> data = json.decode(jsonString);
      _standardWords = data
          .map((item) => WordModel.fromJson(item, level: DifficultyLevel.standard))
          .toList();
    } catch (e, stack) {
      debugPrint('Error loading Standard dictionary: $e\n$stack');
      _standardWords ??= _getSampleStandardWords();
    } finally {
      _isLoadingStandard = false;
    }
  }

  // Load appropriate dictionaries based on level
  static Future<void> loadDictionaries({DifficultyLevel? level}) async {
    if (level == DifficultyLevel.easy) {
      await loadKidsDictionary();
    } else if (level == DifficultyLevel.standard) {
      await loadStandardDictionary();
    } else {
      await Future.wait([
        loadKidsDictionary(),
        loadStandardDictionary(),
      ]);
    }
  }

  // Get all words (combined or by level)
  static Future<List<WordModel>> getAllWords({DifficultyLevel? level}) async {
    if (level == DifficultyLevel.easy) {
      await loadKidsDictionary();
      return _kidsWords ?? _getSampleKidsWords();
    } else if (level == DifficultyLevel.standard) {
      await loadStandardDictionary();
      return _standardWords ?? _getSampleStandardWords();
    } else {
      await loadDictionaries();
      return [
        ...?_kidsWords,
        ...?_standardWords,
      ];
    }
  }

  // Search words with query and optional level filter
  static Future<List<WordModel>> searchWords(String query, {DifficultyLevel? level}) async {
    final effectiveLevel = level ?? DifficultyLevel.easy;
    final List<WordModel> wordsToSearch = await getAllWords(level: effectiveLevel);

    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      // Return first 100 words for instant display
      return wordsToSearch.take(100).toList();
    }

    // Fast search prioritizing prefix matches, then substring matches
    final prefixMatches = <WordModel>[];
    final containsMatches = <WordModel>[];

    for (final word in wordsToSearch) {
      final lower = word.word.toLowerCase();
      if (lower.startsWith(cleanQuery)) {
        prefixMatches.add(word);
        if (prefixMatches.length >= 100) break;
      } else if (prefixMatches.length + containsMatches.length < 100 && lower.contains(cleanQuery)) {
        containsMatches.add(word);
      }
    }

    return [...prefixMatches, ...containsMatches].take(100).toList();
  }

  // Get word of the day (from standard or fallback)
  static Future<WordModel> getWordOfTheDay() async {
    try {
      await loadStandardDictionary();
      final words = _standardWords;
      if (words != null && words.isNotEmpty) {
        final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
        final index = dayOfYear.abs() % words.length;
        return words[index];
      }
    } catch (e) {
      debugPrint('Error getting word of the day: $e');
    }
    return _getSampleStandardWords().first;
  }

  // Get random words for flashcards / study
  static Future<List<WordModel>> getRandomWords({required int count, DifficultyLevel? level}) async {
    final words = await getAllWords(level: level);
    if (words.isEmpty) return _getSampleStandardWords();

    if (words.length <= count) {
      return List<WordModel>.from(words);
    }

    // Pick random indices safely without shuffling the entire 146k list in place
    final results = <WordModel>[];
    final selectedIndices = <int>{};
    final now = DateTime.now().microsecondsSinceEpoch;
    var seed = now;

    while (results.length < count && selectedIndices.length < words.length) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final idx = seed % words.length;
      if (selectedIndices.add(idx)) {
        results.add(words[idx]);
      }
    }

    return results;
  }

  // Sample data fallback in case assets fail to load
  static List<WordModel> _getSampleKidsWords() {
    return [
      WordModel(
        word: 'Beautiful',
        partOfSpeech: 'adjective',
        definition: 'Pleasing to the senses or mind',
        kidFriendlyDefinition: 'Very pretty and nice to look at',
        exampleSentence: 'She wore a beautiful dress to the party.',
        synonyms: ['lovely', 'pretty', 'gorgeous', 'stunning'],
        antonyms: ['ugly', 'hideous'],
        level: DifficultyLevel.easy,
      ),
      WordModel(
        word: 'Cat',
        partOfSpeech: 'noun',
        definition: 'A small domesticated carnivorous mammal',
        kidFriendlyDefinition: 'A small furry pet animal',
        exampleSentence: 'My cat loves to play with yarn.',
        synonyms: ['feline', 'kitten', 'kitty'],
        antonyms: [],
        level: DifficultyLevel.easy,
      ),
      WordModel(
        word: 'Flower',
        partOfSpeech: 'noun',
        definition: 'The reproductive structure of flowering plants',
        kidFriendlyDefinition: 'A colorful part of a plant that blooms and looks pretty',
        exampleSentence: 'I picked a beautiful red flower from the garden.',
        synonyms: ['bloom', 'blossom'],
        antonyms: [],
        level: DifficultyLevel.easy,
      ),
    ];
  }

  static List<WordModel> _getSampleStandardWords() {
    return [
      WordModel(
        word: 'Serendipity',
        partOfSpeech: 'noun',
        definition: 'The occurrence and development of events by chance in a happy or beneficial way',
        exampleSentence: 'Meeting my best friend at that coffee shop was pure serendipity.',
        synonyms: ['luck', 'fortune', 'chance'],
        antonyms: ['misfortune', 'bad luck'],
        frequencyBand: 'Core',
        level: DifficultyLevel.standard,
      ),
      WordModel(
        word: 'Ephemeral',
        partOfSpeech: 'adjective',
        definition: 'Lasting for a very short time',
        exampleSentence: 'The beauty of cherry blossoms is ephemeral.',
        synonyms: ['temporary', 'transient', 'fleeting', 'brief'],
        antonyms: ['permanent', 'eternal', 'lasting'],
        frequencyBand: 'Core',
        level: DifficultyLevel.standard,
      ),
      WordModel(
        word: 'Ubiquitous',
        partOfSpeech: 'adjective',
        definition: 'Present, appearing, or found everywhere',
        exampleSentence: 'Smartphones have become ubiquitous in modern society.',
        synonyms: ['omnipresent', 'universal', 'everywhere'],
        antonyms: ['rare', 'scarce', 'absent'],
        frequencyBand: 'Core',
        level: DifficultyLevel.standard,
      ),
    ];
  }
}
