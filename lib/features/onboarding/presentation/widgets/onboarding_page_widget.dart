// lib/features/onboarding/presentation/widgets/onboarding_page_widget.dart
import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_page_content.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageContent content;

  const OnboardingPageWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          content.imageAsset,
          height: 200,
          color: Colors.white,
        ),
        const SizedBox(height: 40),
        Text(
          content.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            content.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
