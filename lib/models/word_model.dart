class WordModel {
  final String word;
  final String partOfSpeech;
  final String definition;
  final String? kidFriendlyDefinition;
  final String? exampleSentence;
  final List<String> synonyms;
  final List<String> antonyms;
  final String? frequencyBand;
  final DifficultyLevel level;

  WordModel({
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    this.kidFriendlyDefinition,
    this.exampleSentence,
    this.synonyms = const [],
    this.antonyms = const [],
    this.frequencyBand,
    this.level = DifficultyLevel.easy,
  });

  String get pronunciation {
    // Simple pronunciation placeholder
    return '/${word.toLowerCase()}/';
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'part_of_speech': partOfSpeech,
      'full_definition': definition,
      'kid_friendly_definition': kidFriendlyDefinition,
      'example_sentence': exampleSentence,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'frequency_band': frequencyBand,
      'level': level.toString(),
    };
  }

  factory WordModel.fromJson(Map<String, dynamic> json, {DifficultyLevel? level}) {
    return WordModel(
      word: json['word'] ?? '',
      partOfSpeech: json['part_of_speech'] ?? 'noun',
      definition: json['full_definition'] ?? '',
      kidFriendlyDefinition: json['kid_friendly_definition'],
      exampleSentence: json['example_sentence'],
      synonyms: json['synonyms'] != null ? List<String>.from(json['synonyms']) : [],
      antonyms: json['antonyms'] != null ? List<String>.from(json['antonyms']) : [],
      frequencyBand: json['frequency_band'],
      level: level ?? DifficultyLevel.easy,
    );
  }
}

enum DifficultyLevel { easy, standard }

class SavedWord {
  final WordModel word;
  final DateTime savedDate;
  final LearningStatus status;

  SavedWord({
    required this.word,
    required this.savedDate,
    this.status = LearningStatus.toLearn,
  });

  Map<String, dynamic> toJson() {
    return {
      'word': word.toJson(),
      'savedDate': savedDate.toIso8601String(),
      'status': status.toString(),
    };
  }

  factory SavedWord.fromJson(Map<String, dynamic> json) {
    return SavedWord(
      word: WordModel.fromJson(json['word']),
      savedDate: DateTime.parse(json['savedDate']),
      status: LearningStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => LearningStatus.toLearn,
      ),
    );
  }
}

enum LearningStatus { toLearn, learned }
