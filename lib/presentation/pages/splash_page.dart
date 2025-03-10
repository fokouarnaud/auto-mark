import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:correction_auto/presentation/pages/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate loading time (min 2 seconds)
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome_mosaic,
                size: 80,
                color: Colors.white,
              )
                .animate()
                .fade(duration: 500.ms)
                .scale(duration: 700.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'Correction Auto',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              )
                .animate()
                .fade(delay: 300.ms, duration: 500.ms)
                .moveY(begin: 10, end: 0),
              const SizedBox(height: 8),
              Text(
                'Corrigez vos copies plus intelligemment',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              )
                .animate()
                .fade(delay: 500.ms, duration: 500.ms)
                .moveY(begin: 10, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
