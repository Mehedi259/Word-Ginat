import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'contact_support_screen.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & FAQ'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildFaqItem(
                question: 'How do I switch between Kids and Standard mode?',
                answer:
                    'You can switch modes anytime from the Settings tab. Tap on the mode toggle to switch between Kids mode (simplified definitions) and Standard mode (full definitions with etymology).',
                isExpanded: true,
              ),
              const SizedBox(height: 12),
              _buildFaqItem(
                question: 'How does offline mode work?',
                answer:
                    'Download dictionary content from the Offline Downloads section in Settings to use Word Giant without an internet connection.',
              ),
              const SizedBox(height: 12),
              _buildFaqItem(
                question: 'How do study streaks work?',
                answer:
                    'Study streaks track consecutive days of learning. Complete your daily goal each day to maintain your streak and earn achievements.',
              ),
              const SizedBox(height: 12),
              _buildFaqItem(
                question: 'Can I add friends and family members?',
                answer:
                    'Yes! Go to Friends & Rewards in Settings to invite friends and earn free flashcard sets when they make their first purchase.',
              ),
              const SizedBox(height: 12),
              _buildFaqItem(
                question: 'What is included in Premium?',
                answer:
                    'Premium unlocks all flashcard decks, removes ads, provides offline audio, and gives access to advanced vocabulary sets.',
              ),
              const SizedBox(height: 12),
              _buildFaqItem(
                question: 'Are my saved words synced across devices?',
                answer:
                    'Yes, your saved words, progress, and settings are automatically synced when you sign in with your account.',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Still need help?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Our support team is here to help you with any questions or issues.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContactSupportScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Contact Support'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    bool isExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
