import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'learn_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const LearnScreen(),
    const SavedScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  activeIcon: 'assets/images/homeactive.png',
                  inactiveIcon: 'assets/images/home.png',
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  activeIcon: 'assets/images/searchactive.png',
                  inactiveIcon: 'assets/images/search.png',
                  label: 'Search',
                ),
                _buildNavItem(
                  index: 2,
                  activeIcon: 'assets/images/learnactiver.png',
                  inactiveIcon: 'assets/images/learn.png',
                  label: 'Learn',
                ),
                _buildNavItem(
                  index: 3,
                  activeIcon: 'assets/images/savedactive.png',
                  inactiveIcon: 'assets/images/saved.png',
                  label: 'Saved',
                ),
                _buildNavItem(
                  index: 4,
                  activeIcon: 'assets/images/setting active.png',
                  inactiveIcon: 'assets/images/setting.png',
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String activeIcon,
    required String inactiveIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Active indicator bar at top
              Container(
                height: 3,
                width: 30,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0066FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Image.asset(
                isSelected ? activeIcon : inactiveIcon,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image not found
                  return Icon(
                    index == 0
                        ? Icons.home
                        : index == 1
                            ? Icons.search
                            : index == 2
                                ? Icons.book
                                : index == 3
                                    ? Icons.bookmark
                                    : Icons.settings,
                    size: 22,
                    color: isSelected
                        ? const Color(0xFF0066FF)
                        : const Color(0xFF9CA3AF),
                  );
                },
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF0066FF)
                      : const Color(0xFF6B7280),
                  letterSpacing: 0.1,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

