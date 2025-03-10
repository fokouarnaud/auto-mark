import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:correction_auto/presentation/pages/dashboard_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: "Capturez vos copies",
      description: "Prenez en photo les copies de vos élèves directement avec votre appareil mobile",
      icon: Icons.camera_alt_outlined,
    ),
    OnboardingItem(
      title: "Analyse automatique",
      description: "L'application traite automatiquement les réponses avec une technologie OCR avancée",
      icon: Icons.auto_awesome_outlined,
    ),
    OnboardingItem(
      title: "Correction intelligente",
      description: "Comparez les réponses avec vos références et attribuez des notes rapidement",
      icon: Icons.grading_outlined,
    ),
    OnboardingItem(
      title: "Analyses statistiques",
      description: "Visualisez la progression et identifiez les points d'amélioration",
      icon: Icons.analytics_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const DashboardPage()),
                  );
                },
                child: Text('Passer'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  return _OnboardingItemWidget(
                    item: _onboardingItems[index],
                    isActive: _currentPage == index,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Row(
                    children: List.generate(
                      _onboardingItems.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 8,
                        width: index == _currentPage ? 24 : 8,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? AppColors.primary
                              : AppColors.outlineLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // Next button
                  ElevatedButton(
                    onPressed: _goToNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage < _onboardingItems.length - 1
                          ? 'Suivant'
                          : 'Commencer',
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
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _OnboardingItemWidget extends StatelessWidget {
  final OnboardingItem item;
  final bool isActive;

  const _OnboardingItemWidget({
    required this.item,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 64,
              color: AppColors.primary,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fade(duration: 600.ms)
              .scale(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 40),
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          )
              .animate(target: isActive ? 1 : 0)
              .fade(delay: 300.ms, duration: 600.ms)
              .moveY(begin: 20, end: 0),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          )
              .animate(target: isActive ? 1 : 0)
              .fade(delay: 500.ms, duration: 600.ms)
              .moveY(begin: 20, end: 0),
        ],
      ),
    );
  }
}
