import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/image_mapper.dart';
import '../data/dictionary_data.dart';
import '../models/word_model.dart';
import '../services/storage_service.dart';
import 'word_detail_screen.dart';
import 'search_screen.dart';
import 'saved_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WordModel? _wordOfTheDay;
  int _kidsWordCount = 0;
  int _standardWordCount = 0;
  int _totalWordCount = 0;
  int _savedWordCount = 0;
  int _wordsLearnedToday = 0;
  int _dailyGoal = 10;
  int _streakCount = 0;
  int _totalLearned = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load word of the day
    final word = await DictionaryData.getWordOfTheDay();
    
    // Load word counts
    final kidsWords = await DictionaryData.getAllWords(level: DifficultyLevel.easy);
    final standardWords = await DictionaryData.getAllWords(level: DifficultyLevel.standard);
    final allWords = await DictionaryData.getAllWords();
    
    // Load user stats from storage
    final savedCount = await StorageService.getSavedWordsCount();
    final learnedToday = await StorageService.getWordsLearnedToday();
    final goal = await StorageService.getDailyGoal();
    final streak = await StorageService.getStreak();
    final totalLearned = await StorageService.getTotalWordsLearned();
    
    setState(() {
      _wordOfTheDay = word;
      _kidsWordCount = kidsWords.length;
      _standardWordCount = standardWords.length;
      _totalWordCount = allWords.length;
      _savedWordCount = savedCount;
      _wordsLearnedToday = learnedToday;
      _dailyGoal = goal;
      _streakCount = streak;
      _totalLearned = totalLearned;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGrey,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final wordOfTheDay = _wordOfTheDay!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello, Learner! 👋',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to expand your vocabulary?',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryBlue,
                    child: const Text(
                      'L',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Word of the Day Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordDetailScreen(word: wordOfTheDay),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFFB347)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text(
                            'Word of the Day',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        wordOfTheDay.word.toLowerCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wordOfTheDay.partOfSpeech,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        wordOfTheDay.definition,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Today's Goal Card
              GestureDetector(
                onTap: () {
                  // Navigate to Learn screen (flashcards)
                  DefaultTabController.of(context)?.animateTo(2); // Index 2 is Learn screen
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s Goal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_wordsLearnedToday/$_dailyGoal words',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _dailyGoal > 0 ? (_wordsLearnedToday / _dailyGoal).clamp(0.0, 1.0) : 0.0,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(_dailyGoal > 0 ? (_wordsLearnedToday / _dailyGoal * 100).clamp(0.0, 100.0) : 0.0).toStringAsFixed(0)}% — ${_wordsLearnedToday >= _dailyGoal ? 'Goal completed! 🎉' : 'Tap to study flashcards'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department,
                                  color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$_streakCount day${_streakCount != 1 ? 's' : ''} streak',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$_totalLearned all time',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
              const SizedBox(height: 24),

              // Quick Access Section
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildQuickAccessCard(
                    icon: Icons.book,
                    title: _formatNumber(_kidsWordCount),
                    subtitle: 'Kids Dictionary',
                    color: const Color(0xFFFF6B6B),
                    onTap: () {
                      // Navigate to search with Kids level
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickAccessCard(
                    icon: Icons.school,
                    title: _formatNumber(_standardWordCount),
                    subtitle: 'Standard',
                    color: const Color(0xFFFFB347),
                    onTap: () {
                      // Navigate to search with Standard level
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickAccessCard(
                    icon: Icons.bookmark,
                    title: _formatNumber(_savedWordCount),
                    subtitle: 'Saved',
                    color: const Color(0xFF51CF66),
                    onTap: () {
                      // Navigate to saved screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickAccessCard(
                    icon: Icons.style,
                    title: _formatNumber(_totalWordCount),
                    subtitle: 'Total Words',
                    color: const Color(0xFF667EEA),
                    onTap: () {
                      // Navigate to search
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickAccessCard(
                    icon: Icons.workspace_premium,
                    title: '0',
                    subtitle: 'Premium',
                    color: const Color(0xFFFFC107),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Premium features coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  _buildQuickAccessCard(
                    icon: Icons.image,
                    title: ImageMapper.imageCount.toString(),
                    subtitle: 'Visual',
                    color: const Color(0xFFFF4081),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${ImageMapper.imageCount} words with images available in Kids mode!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
