import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';

class StorageService {
  static SharedPreferences? _prefs;
  
  // Keys for storage
  static const String _savedWordsKey = 'saved_words';
  static const String _recentSearchesKey = 'recent_searches';
  static const String _learnedWordsKey = 'learned_words';
  static const String _dailyGoalKey = 'daily_goal';
  static const String _wordsLearnedTodayKey = 'words_learned_today';
  static const String _lastActiveDate = 'last_active_date';
  static const String _streakCountKey = 'streak_count';
  static const String _totalWordsLearnedKey = 'total_words_learned';
  static const String _quizScoresKey = 'quiz_scores';
  
  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }
  
  // ==================== SAVED WORDS ====================
  
  static Future<void> saveWord(WordModel word) async {
    final savedWords = await getSavedWords();
    
    // Check if word already exists
    if (!savedWords.any((w) => w.word.word.toLowerCase() == word.word.toLowerCase())) {
      final savedWord = SavedWord(
        word: word,
        savedDate: DateTime.now(),
        status: LearningStatus.toLearn,
      );
      savedWords.add(savedWord);
      
      // Save to storage
      final jsonList = savedWords.map((w) => w.toJson()).toList();
      await prefs.setString(_savedWordsKey, json.encode(jsonList));
    }
  }
  
  static Future<void> unsaveWord(String word) async {
    final savedWords = await getSavedWords();
    savedWords.removeWhere((w) => w.word.word.toLowerCase() == word.toLowerCase());
    
    final jsonList = savedWords.map((w) => w.toJson()).toList();
    await prefs.setString(_savedWordsKey, json.encode(jsonList));
  }
  
  static Future<List<SavedWord>> getSavedWords() async {
    final jsonString = prefs.getString(_savedWordsKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => SavedWord.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing saved words: $e');
      return [];
    }
  }
  
  static Future<bool> isWordSaved(String word) async {
    final savedWords = await getSavedWords();
    return savedWords.any((w) => w.word.word.toLowerCase() == word.toLowerCase());
  }
  
  static Future<int> getSavedWordsCount() async {
    final savedWords = await getSavedWords();
    return savedWords.length;
  }
  
  // ==================== LEARNED WORDS ====================
  
  static Future<void> markWordAsLearned(String word) async {
    final learnedWords = await getLearnedWords();
    if (!learnedWords.contains(word.toLowerCase())) {
      learnedWords.add(word.toLowerCase());
      await prefs.setStringList(_learnedWordsKey, learnedWords);
      
      // Update today's count
      await _updateWordsLearnedToday();
      
      // Update total count
      final total = prefs.getInt(_totalWordsLearnedKey) ?? 0;
      await prefs.setInt(_totalWordsLearnedKey, total + 1);
      
      // Update streak
      await _updateStreak();
    }
    
    // Also update saved word status if it exists
    final savedWords = await getSavedWords();
    final index = savedWords.indexWhere((w) => w.word.word.toLowerCase() == word.toLowerCase());
    if (index != -1) {
      savedWords[index] = SavedWord(
        word: savedWords[index].word,
        savedDate: savedWords[index].savedDate,
        status: LearningStatus.learned,
      );
      final jsonList = savedWords.map((w) => w.toJson()).toList();
      await prefs.setString(_savedWordsKey, json.encode(jsonList));
    }
  }
  
  static Future<List<String>> getLearnedWords() async {
    return prefs.getStringList(_learnedWordsKey) ?? [];
  }
  
  static Future<bool> isWordLearned(String word) async {
    final learnedWords = await getLearnedWords();
    return learnedWords.contains(word.toLowerCase());
  }
  
  // ==================== RECENT SEARCHES ====================
  
  static Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final searches = await getRecentSearches();
    
    // Remove if already exists
    searches.remove(query);
    
    // Add to beginning
    searches.insert(0, query);
    
    // Keep only last 20 searches
    if (searches.length > 20) {
      searches.removeRange(20, searches.length);
    }
    
    await prefs.setStringList(_recentSearchesKey, searches);
  }
  
  static Future<List<String>> getRecentSearches() async {
    return prefs.getStringList(_recentSearchesKey) ?? [];
  }
  
  static Future<void> clearRecentSearches() async {
    await prefs.remove(_recentSearchesKey);
  }
  
  // ==================== DAILY GOAL & PROGRESS ====================
  
  static Future<void> setDailyGoal(int goal) async {
    await prefs.setInt(_dailyGoalKey, goal);
  }
  
  static Future<int> getDailyGoal() async {
    return prefs.getInt(_dailyGoalKey) ?? 10; // Default 10 words
  }
  
  static Future<int> getWordsLearnedToday() async {
    final lastDate = prefs.getString(_lastActiveDate);
    final today = _getTodayString();
    
    if (lastDate != today) {
      // Reset count for new day
      await prefs.setInt(_wordsLearnedTodayKey, 0);
      await prefs.setString(_lastActiveDate, today);
      return 0;
    }
    
    return prefs.getInt(_wordsLearnedTodayKey) ?? 0;
  }
  
  static Future<void> _updateWordsLearnedToday() async {
    final count = await getWordsLearnedToday();
    await prefs.setInt(_wordsLearnedTodayKey, count + 1);
  }
  
  static Future<double> getTodayProgress() async {
    final goal = await getDailyGoal();
    final learned = await getWordsLearnedToday();
    return goal > 0 ? (learned / goal).clamp(0.0, 1.0) : 0.0;
  }
  
  // ==================== STREAK ====================
  
  static Future<void> _updateStreak() async {
    final lastDate = prefs.getString(_lastActiveDate);
    final today = _getTodayString();
    
    if (lastDate == null) {
      // First time
      await prefs.setInt(_streakCountKey, 1);
      await prefs.setString(_lastActiveDate, today);
    } else if (lastDate != today) {
      final lastDateTime = DateTime.parse(lastDate);
      final todayDateTime = DateTime.parse(today);
      final difference = todayDateTime.difference(lastDateTime).inDays;
      
      if (difference == 1) {
        // Consecutive day
        final streak = prefs.getInt(_streakCountKey) ?? 0;
        await prefs.setInt(_streakCountKey, streak + 1);
      } else if (difference > 1) {
        // Streak broken
        await prefs.setInt(_streakCountKey, 1);
      }
      
      await prefs.setString(_lastActiveDate, today);
    }
  }
  
  static Future<int> getStreak() async {
    final lastDate = prefs.getString(_lastActiveDate);
    if (lastDate == null) return 0;
    
    final lastDateTime = DateTime.parse(lastDate);
    final today = DateTime.now();
    final difference = today.difference(lastDateTime).inDays;
    
    if (difference > 1) {
      // Streak broken
      await prefs.setInt(_streakCountKey, 0);
      return 0;
    }
    
    return prefs.getInt(_streakCountKey) ?? 0;
  }
  
  // ==================== TOTAL STATS ====================
  
  static Future<int> getTotalWordsLearned() async {
    return prefs.getInt(_totalWordsLearnedKey) ?? 0;
  }
  
  // ==================== QUIZ SCORES ====================
  
  static Future<void> saveQuizScore(int score, int total) async {
    final scores = await getQuizScores();
    scores.add({
      'score': score,
      'total': total,
      'date': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 50 scores
    if (scores.length > 50) {
      scores.removeRange(0, scores.length - 50);
    }
    
    await prefs.setString(_quizScoresKey, json.encode(scores));
  }
  
  static Future<List<Map<String, dynamic>>> getQuizScores() async {
    final jsonString = prefs.getString(_quizScoresKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error parsing quiz scores: $e');
      return [];
    }
  }
  
  static Future<double> getAverageQuizScore() async {
    final scores = await getQuizScores();
    if (scores.isEmpty) return 0.0;
    
    double totalPercentage = 0.0;
    for (var score in scores) {
      final percentage = (score['score'] as int) / (score['total'] as int);
      totalPercentage += percentage;
    }
    
    return totalPercentage / scores.length;
  }
  
  // ==================== HELPER METHODS ====================
  
  static String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
  
  // Clear all data (useful for testing or reset)
  static Future<void> clearAll() async {
    await prefs.clear();
  }
}
