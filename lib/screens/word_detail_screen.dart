import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/app_theme.dart';
import '../utils/image_mapper.dart';
import '../models/word_model.dart';
import '../services/storage_service.dart';

class WordDetailScreen extends StatefulWidget {
  final WordModel word;

  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSaved = false;
  DifficultyLevel _selectedLevel = DifficultyLevel.easy;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.word.level;
    _initTts();
    _checkIfSaved();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _checkIfSaved() async {
    final isSaved = await StorageService.isWordSaved(widget.word.word);
    setState(() {
      _isSaved = isSaved;
    });
  }

  Future<void> _speak() async {
    await _flutterTts.speak(widget.word.word);
  }

  Future<void> _toggleSave() async {
    if (_isSaved) {
      await StorageService.unsaveWord(widget.word.word);
    } else {
      await StorageService.saveWord(widget.word);
    }
    
    setState(() {
      _isSaved = !_isSaved;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved
                ? 'Word saved!'
                : 'Word removed from saved',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // Helper method to get image path for a word
  String? _getImagePath() {
    // First check if word model has an explicit image path
    if (widget.word.imagePath != null) {
      return widget.word.imagePath;
    }
    
    // Use ImageMapper to find image for this word
    return ImageMapper.getImagePath(widget.word.word);
  }

  bool _hasImage() {
    return _getImagePath() != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  // Level Toggles
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildLevelToggle('Easy', DifficultyLevel.easy),
                        const SizedBox(width: 8),
                        _buildLevelToggle('Standard', DifficultyLevel.standard),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Word Title and Save Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.word.word,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleSave,
                          icon: Icon(
                            _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                            color: _isSaved
                                ? AppTheme.primaryBlue
                                : AppTheme.textGrey,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Pronunciation
                    GestureDetector(
                      onTap: _speak,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.volume_up,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.word.pronunciation,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Part of Speech
                    Text(
                      widget.word.partOfSpeech,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Image (if Easy mode and has image)
                    if (_selectedLevel == DifficultyLevel.easy && _hasImage()) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.image,
                                size: 16,
                                color: AppTheme.primaryPurple,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'VISUAL REFERENCE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryPurple,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 240,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                _getImagePath()!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback if image not found
                                  return Container(
                                    color: Colors.blue[50],
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported,
                                            size: 60,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Image not available',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Definition Section
                    const Text(
                      'DEFINITION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedLevel == DifficultyLevel.easy
                          ? (widget.word.kidFriendlyDefinition ?? widget.word.definition)
                          : widget.word.definition,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Example (if available)
                    if (widget.word.exampleSentence != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFE082),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  color: Color(0xFFFFA726),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'EXAMPLE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '"${widget.word.exampleSentence}"',
                              style: const TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Synonyms (if Standard mode)
                    if (_selectedLevel == DifficultyLevel.standard &&
                        widget.word.synonyms.isNotEmpty) ...[
                      const Text(
                        'SYNONYMS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textGrey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.word.synonyms
                            .map((syn) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                  child: Text(
                                    syn,
                                    style: const TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Antonyms (if Standard mode)
                    if (_selectedLevel == DifficultyLevel.standard &&
                        widget.word.antonyms.isNotEmpty) ...[
                      const Text(
                        'ANTONYMS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textGrey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.word.antonyms
                            .map((ant) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.primaryRed,
                                    ),
                                  ),
                                  child: Text(
                                    ant,
                                    style: const TextStyle(
                                      color: AppTheme.primaryRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Etymology (if Standard mode)
                    if (_selectedLevel == DifficultyLevel.standard &&
                        widget.word.frequencyBand != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FREQUENCY BAND',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textGrey,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.word.frequencyBand!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelToggle(String label, DifficultyLevel level) {
    final isSelected = _selectedLevel == level;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppTheme.primaryPurple, Color(0xFFD946EF)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isSelected && level == DifficultyLevel.standard)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.school, color: Colors.white, size: 16),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
