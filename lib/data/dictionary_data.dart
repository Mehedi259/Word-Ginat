import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word_model.dart';

class DictionaryData {
  static List<WordModel>? _kidsWords;
  static List<WordModel>? _standardWords;
  static bool _isLoading = false;

  // Load dictionary data from JSON files
  static Future<void> loadDictionaries() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      // Load Kids Dictionary
      if (_kidsWords == null) {
        final kidsJson = await rootBundle.loadString('assets/data/Kids_Dictionary_Final_Refined.json');
        final List<dynamic> kidsData = json.decode(kidsJson);
        _kidsWords = kidsData
            .map((item) => WordModel.fromJson(item, level: DifficultyLevel.easy))
            .toList();
      }

      // Load Standard Dictionary
      if (_standardWords == null) {
        final standardJson = await rootBundle.loadString('assets/data/Standard_Dictionary_Final_Refined.json');
        final List<dynamic> standardData = json.decode(standardJson);
        _standardWords = standardData
            .map((item) => WordModel.fromJson(item, level: DifficultyLevel.standard))
            .toList();
      }
    } catch (e) {
      print('Error loading dictionaries: $e');
      // Fallback to sample data if loading fails
      _kidsWords = _getSampleKidsWords();
      _standardWords = _getSampleStandardWords();
    }

    _isLoading = false;
  }

  // Get all words (combined or by level)
  static Future<List<WordModel>> getAllWords({DifficultyLevel? level}) async {
    await loadDictionaries();

    if (level == DifficultyLevel.easy) {
      return _kidsWords ?? [];
    } else if (level == DifficultyLevel.standard) {
      return _standardWords ?? [];
    } else {
      return [...?_kidsWords, ...?_standardWords];
    }
  }

  // Search words with query and optional level filter
  static Future<List<WordModel>> searchWords(String query, {DifficultyLevel? level}) async {
    await loadDictionaries();

    List<WordModel> wordsToSearch;
    if (level == DifficultyLevel.easy) {
      wordsToSearch = _kidsWords ?? [];
    } else if (level == DifficultyLevel.standard) {
      wordsToSearch = _standardWords ?? [];
    } else {
      wordsToSearch = [...?_kidsWords, ...?_standardWords];
    }

    if (query.isEmpty) {
      // Return first 100 words if no query
      return wordsToSearch.take(100).toList();
    }

    final searchQuery = query.toLowerCase();
    final results = wordsToSearch.where((word) {
      return word.word.toLowerCase().contains(searchQuery);
    }).take(100).toList(); // Limit to 100 results for performance

    return results;
  }

  // Get word of the day (random word from standard dictionary)
  static Future<WordModel> getWordOfTheDay() async {
    await loadDictionaries();
    
    final standardWords = _standardWords ?? _getSampleStandardWords();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final index = dayOfYear % standardWords.length;
    
    return standardWords[index];
  }

  // Get random words for flashcards
  static Future<List<WordModel>> getRandomWords({required int count, DifficultyLevel? level}) async {
    await loadDictionaries();

    List<WordModel> sourceWords;
    if (level == DifficultyLevel.easy) {
      sourceWords = _kidsWords ?? [];
    } else if (level == DifficultyLevel.standard) {
      sourceWords = _standardWords ?? [];
    } else {
      sourceWords = [...?_kidsWords, ...?_standardWords];
    }

    if (sourceWords.length <= count) {
      return sourceWords;
    }

    // Get random words
    final random = DateTime.now().millisecondsSinceEpoch;
    sourceWords.shuffle();
    return sourceWords.take(count).toList();
  }

  // Sample data for fallback
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
