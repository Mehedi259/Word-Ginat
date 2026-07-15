import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/image_mapper.dart';
import '../data/dictionary_data.dart';
import '../models/word_model.dart';
import 'word_detail_screen.dart';

class VisualWordsScreen extends StatefulWidget {
  const VisualWordsScreen({super.key});

  @override
  State<VisualWordsScreen> createState() => _VisualWordsScreenState();
}

class _VisualWordsScreenState extends State<VisualWordsScreen> {
  List<WordModel> _wordsWithImages = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<WordModel> _filteredWords = [];

  @override
  void initState() {
    super.initState();
    _loadWordsWithImages();
  }

  Future<void> _loadWordsWithImages() async {
    // Load kids dictionary
    final kidsWords = await DictionaryData.getAllWords(level: DifficultyLevel.easy);
    
    // Filter words that have images
    final wordsWithImages = kidsWords.where((word) {
      return ImageMapper.hasImage(word.word);
    }).toList();
    
    // Sort alphabetically
    wordsWithImages.sort((a, b) => a.word.compareTo(b.word));
    
    setState(() {
      _wordsWithImages = wordsWithImages;
      _filteredWords = wordsWithImages;
      _isLoading = false;
    });
  }

  void _filterWords(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredWords = _wordsWithImages;
      });
    } else {
      final filtered = _wordsWithImages.where((word) {
        return word.word.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      setState(() {
        _filteredWords = filtered;
      });
    }
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
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visual Dictionary',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Words with images',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_wordsWithImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: _filterWords,
                decoration: InputDecoration(
                  hintText: 'Search visual words...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textGrey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.textGrey),
                          onPressed: () {
                            _searchController.clear();
                            _filterWords('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Loading or Word Grid
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_filteredWords.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: AppTheme.textGrey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No visual words found',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _filteredWords.length,
                  itemBuilder: (context, index) {
                    return _buildWordCard(_filteredWords[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard(WordModel word) {
    final imagePath = ImageMapper.getImagePath(word.word);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WordDetailScreen(word: word),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (imagePath != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Word Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      word.word,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        word.partOfSpeech,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
