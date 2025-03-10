import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:correction_auto/core/theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool showButton;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.showButton = false,
    this.buttonText = 'Action',
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            )
                .animate()
                .fade(duration: 500.ms)
                .scale(delay: 200.ms, duration: 500.ms),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fade(delay: 300.ms, duration: 500.ms)
                .moveY(begin: 10, end: 0),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fade(delay: 500.ms, duration: 500.ms)
                .moveY(begin: 10, end: 0),
            if (showButton) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(buttonText),
              )
                  .animate()
                  .fade(delay: 700.ms, duration: 500.ms),
            ],
          ],
        ),
      ),
    );
  }
}
