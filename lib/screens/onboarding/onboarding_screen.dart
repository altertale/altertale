import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/router.dart';

/// Onboarding Screen
///
/// User introduction and app features showcase:
/// - Multi-page feature introduction
/// - Page indicators and navigation
/// - Skip and continue buttons
/// - Smooth page transitions
/// - Route to authentication screens
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // ==================== STATE ====================
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ==================== ONBOARDING DATA ====================
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Hikayeler Keşfedin',
      description:
          'Binlerce kaliteli hikaye ve roman arasından size uygun olanları bulun. Farklı kategorilerden seçiminizi yapın.',
      icon: Icons.library_books_rounded,
      color: Colors.blue,
    ),
    OnboardingPage(
      title: 'Okuma Deneyimi',
      description:
          'Gelişmiş okuma araçları ile hikayeleri istediğiniz şekilde okuyun. Karanlık mod, yazı boyutu ve daha fazlası.',
      icon: Icons.auto_stories_rounded,
      color: Colors.green,
    ),
    OnboardingPage(
      title: 'Sosyal Etkileşim',
      description:
          'Hikayeleri beğenin, yorum yapın ve diğer okuyucularla etkileşime geçin. Kendi listelerinizi oluşturun.',
      icon: Icons.people_rounded,
      color: Colors.orange,
    ),
    OnboardingPage(
      title: 'Premium Özellikler',
      description:
          'Premium üyelik ile reklamsız okuma, özel içerikler ve gelişmiş özelliklere erişim sağlayın.',
      icon: Icons.star_rounded,
      color: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ==================== PAGE NAVIGATION ====================

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _skipOnboarding() {
    _goToLogin();
  }

  void _goToLogin() {
    context.go(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Atla',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(context, page);
                },
              ),
            ),

            // Page Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _pages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final isActive = index == _currentPage;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Geri'),
                      ),
                    ),

                  if (_currentPage > 0) const SizedBox(width: 16),

                  Expanded(
                    flex: _currentPage == 0 ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Devam'
                            : 'Başlayalım',
                      ),
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

  Widget _buildPage(BuildContext context, OnboardingPage page) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(page.icon, size: 60, color: page.color),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Onboarding Page Data Model
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
