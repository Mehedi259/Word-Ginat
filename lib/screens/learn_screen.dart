import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';
import 'flashcard_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _savedWordsCount = 0;
  int _wordsLearnedToday = 0;
  int _totalLearned = 0;
  int _allWordsProgress = 0;
  int _savedWordsProgress = 0;
  int _kidsWordsProgress = 0;
  int _standardWordsProgress = 0;
  int _mixedWordsProgress = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final saved = await StorageService.getSavedWordsCount();
    final today = await StorageService.getWordsLearnedToday();
    final total = await StorageService.getTotalWordsLearned();

    setState(() {
      _savedWordsCount = saved;
      _wordsLearnedToday = today;
      _totalLearned = total;
      _allWordsProgress = StorageService.getDeckProgress('All Words');
      _savedWordsProgress = StorageService.getDeckProgress('Saved Words');
      _kidsWordsProgress = StorageService.getDeckProgress('Kids Dictionary');
      _standardWordsProgress = StorageService.getDeckProgress('Standard Dictionary');
      _mixedWordsProgress = StorageService.getDeckProgress('Mixed Practice');
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Learn',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a deck to practice',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'PRACTICE DECKS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textGrey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildDeckCard(
                context,
                title: 'All Words',
                totalCards: 100,
                completed: _allWordsProgress > 100 ? 100 : _allWordsProgress,
                icon: Icons.menu_book,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 12),
              _buildDeckCard(
                context,
                title: 'Saved Words',
                totalCards: _savedWordsCount > 0 ? _savedWordsCount : 1,
                completed: _savedWordsProgress,
                icon: Icons.bookmark,
                color: const Color(0xFF51CF66),
              ),
              const SizedBox(height: 12),
              _buildDeckCard(
                context,
                title: 'Kids Dictionary',
                totalCards: 30,
                completed: _kidsWordsProgress > 30 ? 30 : _kidsWordsProgress,
                icon: Icons.child_care,
                color: const Color(0xFF9C27B0),
              ),
              const SizedBox(height: 12),
              _buildDeckCard(
                context,
                title: 'Standard Dictionary',
                totalCards: 40,
                completed: _standardWordsProgress > 40 ? 40 : _standardWordsProgress,
                icon: Icons.school,
                color: const Color(0xFFE91E63),
              ),
              const SizedBox(height: 12),
              _buildDeckCard(
                context,
                title: 'Mixed Practice',
                totalCards: 60,
                completed: _mixedWordsProgress > 60 ? 60 : _mixedWordsProgress,
                icon: Icons.shuffle,
                color: const Color(0xFF00BCD4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeckCard(
    BuildContext context, {
    required String title,
    required int totalCards,
    required int completed,
    required IconData icon,
    required Color color,
  }) {
    final percentage = totalCards > 0 ? (completed / totalCards * 100).round() : 0;

    return GestureDetector(
      onTap: () async {
        // Navigate to flashcard screen and wait for result
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlashcardScreen(deckTitle: title),
          ),
        );
        
        // Refresh stats if quiz was completed
        if (result == true && mounted) {
          _loadStats();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalCards cards',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: completed / totalCards,
                            minHeight: 6,
                            backgroundColor: color.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed / $totalCards completed',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.textGrey, size: 16),
          ],
        ),
      ),
    );
  }
}
