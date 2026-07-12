import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../data/dictionary_data.dart';
import '../models/word_model.dart';
import '../services/storage_service.dart';
import 'word_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<WordModel> _searchResults = [];
  DifficultyLevel? _selectedLevel = DifficultyLevel.easy;
  List<String> _recentSearches = ['Beloved'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Load saved reading mode
    final mode = StorageService.prefs.getString('reading_mode') ?? 'easy';
    _selectedLevel = mode == 'easy' ? DifficultyLevel.easy : DifficultyLevel.standard;
    
    final results = await DictionaryData.searchWords('', level: _selectedLevel);
    final recent = await StorageService.getRecentSearches();
    setState(() {
      _searchResults = results;
      _recentSearches = recent.take(5).toList();
    });
  }

  Future<void> _performSearch(String query) async {
    final results = await DictionaryData.searchWords(query, level: _selectedLevel);
    setState(() {
      _searchResults = results;
    });
    
    if (query.isNotEmpty) {
      await StorageService.addRecentSearch(query);
      final recent = await StorageService.getRecentSearches();
      setState(() {
        _recentSearches = recent.take(5).toList();
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search words...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textGrey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.textGrey),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
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

            // Level Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildLevelButton(
                      label: 'Easy',
                      icon: Icons.child_care,
                      level: DifficultyLevel.easy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLevelButton(
                      label: 'Standard',
                      icon: Icons.school,
                      level: DifficultyLevel.standard,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Results or Recent Searches
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildRecentSearches()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton({
    required String label,
    required IconData icon,
    required DifficultyLevel level,
  }) {
    final isSelected = _selectedLevel == level;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = level;
        });
        _performSearch(_searchController.text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppTheme.primaryPurple, Color(0xFFD946EF)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textGrey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suggested words based on search
          if (_searchResults.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final word = _searchResults[index];
                return _buildWordItem(word);
              },
            ),
          ],
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Recent Searches..',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Show recent searches without async calls
          if (_recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: _recentSearches.map((searchTerm) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.history, size: 20, color: AppTheme.textGrey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            searchTerm,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, size: 20),
                          onPressed: () {
                            _searchController.text = searchTerm;
                            _performSearch(searchTerm);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textGrey.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No words found',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildWordItem(_searchResults[index]);
      },
    );
  }

  Widget _buildWordItem(WordModel word, {bool isRecent = false}) {
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
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (isRecent)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.history, size: 20, color: AppTheme.textGrey),
              ),
            if (isRecent) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.partOfSpeech,
                    style: TextStyle(
                      fontSize: 14,
                      color: word.level == DifficultyLevel.easy
                          ? AppTheme.primaryPurple
                          : AppTheme.primaryBlue,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
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
