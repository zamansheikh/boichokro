import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/constants.dart';

/// Onboarding Page - Introduction slides
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      icon: Icons.search_rounded,
      title: 'Discover Books Nearby',
      description:
          'Find books available for exchange or donation in your area. Connect with readers around you.',
      colors: [Color(0xFF00695C), Color(0xFF00897B)],
    ),
    OnboardingSlide(
      icon: Icons.swap_horiz_rounded,
      title: 'Exchange or Donate',
      description:
          'Choose to exchange books with others or donate them freely. Share knowledge, spread joy.',
      colors: [Color(0xFFD84315), Color(0xFFFF6F00)],
    ),
    OnboardingSlide(
      icon: Icons.chat_bubble_rounded,
      title: 'Connect with Readers',
      description:
          'Chat with book owners, arrange pickups, and build a community of book lovers.',
      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _navigateToAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.hasSkippedOnboardingKey, true);
    if (mounted) {
      context.go('/auth');
    }
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToAuth();
    }
  }

  void _skip() {
    _navigateToAuth();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              slide.colors[0].withValues(alpha: 0.1),
              slide.colors[1].withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: slide.colors[0],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return _buildSlide(_slides[index]);
                  },
                ),
              ),
              // Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => _buildDot(index),
                ),
              ),
              const SizedBox(height: 32),
              // Next/Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: slide.colors[0],
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _currentPage == _slides.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: slide.colors,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: slide.colors[0].withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(slide.icon, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 56),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: slide.colors[0],
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final color = _slides[_currentPage].colors[0];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? color : color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> colors;

  OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.colors,
  });
}
