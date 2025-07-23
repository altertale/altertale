import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/widgets.dart';

/// Onboarding Screen - Kullanıcı Tanıtım Ekranı
///
/// Bu ekran yeni kullanıcılar için uygulamanın özelliklerini
/// tanıtan sayfalı bir ekrandır.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.library_books,
      title: 'Binlerce Hikaye',
      description:
          'Farklı kategorilerde binlerce hikaye ve kitabı keşfedin. '
          'Her zevke uygun içerikler sizi bekliyor.',
      color: Colors.blue,
    ),
    OnboardingPageData(
      icon: Icons.favorite,
      title: 'Kişiselleştirilmiş Deneyim',
      description:
          'Okuma alışkanlıklarınıza göre öneriler alın. '
          'Favori yazarlarınızı takip edin ve yeni keşifler yapın.',
      color: Colors.purple,
    ),
    OnboardingPageData(
      icon: Icons.offline_bolt,
      title: 'Offline Okuma',
      description:
          'Kitapları indirip internet bağlantısı olmadan okuyun. '
          'Her zaman her yerde hikayelerinizle olun.',
      color: Colors.green,
    ),
    OnboardingPageData(
      icon: Icons.group,
      title: 'Topluluk',
      description:
          'Diğer okuyucularla etkileşim kurun, yorumlar paylaşın '
          've kitap önerilerinde bulunun.',
      color: Colors.orange,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: SubtitleText('Geç', color: colorScheme.primary),
                ),
              ),
            ),

            // Page View
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
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // Previous Button (show only if not first page)
                  if (_currentPage > 0) ...[
                    Expanded(
                      child: CustomButton(
                        text: 'Geri',
                        isPrimary: false,
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Next/Start Button
                  Expanded(
                    flex: _currentPage > 0 ? 1 : 2,
                    child: CustomButton(
                      text: _currentPage == _pages.length - 1
                          ? 'Başlayalım'
                          : 'Devam',
                      onPressed: _nextPage,
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

  Widget _buildPage(OnboardingPageData pageData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: pageData.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(pageData.icon, size: 60, color: pageData.color),
          ),

          const SizedBox(height: 40),

          // Title
          TitleText(
            pageData.title,
            size: TitleSize.headline,
            textAlign: TextAlign.center,
            color: colorScheme.onSurface,
          ),

          const SizedBox(height: 20),

          // Description
          SubtitleText(
            pageData.description,
            size: SubtitleSize.large,
            textAlign: TextAlign.center,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = index == _currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Onboarding Page Data Model
class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
