// lib/features/onboarding/presentation/pages/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_page_widget.dart';
import '../../../../config/routes/app_router.dart';

@RoutePage()
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: Scaffold(
        body: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            return Stack(
              children: [
                PageView.builder(
                  itemCount: state.pages.length,
                  onPageChanged: (index) {
                    if (index > state.currentPageIndex) {
                      context.read<OnboardingBloc>().add(NextPage());
                    } else {
                      context.read<OnboardingBloc>().add(PreviousPage());
                    }
                  },
                  itemBuilder: (context, index) {
                    return OnboardingPageWidget(content: state.pages[index]);
                  },
                ),
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          state.pages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == state.currentPageIndex
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.router.push(const LoginRoute());
                        },
                        child: const Text('Go to Login'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
