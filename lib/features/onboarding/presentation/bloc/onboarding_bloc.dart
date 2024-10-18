// lib/features/onboarding/presentation/bloc/onboarding_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/onboarding_page_content.dart';

abstract class OnboardingEvent {}

class NextPage extends OnboardingEvent {}

class PreviousPage extends OnboardingEvent {}

class OnboardingState {
  final List<OnboardingPageContent> pages;
  final int currentPageIndex;

  OnboardingState({
    required this.pages,
    this.currentPageIndex = 0,
  });

  OnboardingState copyWith({
    List<OnboardingPageContent>? pages,
    int? currentPageIndex,
  }) {
    return OnboardingState(
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }
}

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc()
      : super(OnboardingState(pages: [
          OnboardingPageContent(
            title: 'Welcome',
            description: 'Welcome to our amazing app!',
            imageAsset: 'assets/onboarding1.png',
          ),
          OnboardingPageContent(
            title: 'Discover',
            description: 'Discover amazing features!',
            imageAsset: 'assets/onboarding2.png',
          ),
          OnboardingPageContent(
            title: 'Get Started',
            description: 'Let\'s get started!',
            imageAsset: 'assets/onboarding3.png',
          ),
        ])) {
    on<NextPage>(_onNextPage);
    on<PreviousPage>(_onPreviousPage);
  }

  void _onNextPage(NextPage event, Emitter<OnboardingState> emit) {
    if (state.currentPageIndex < state.pages.length - 1) {
      emit(state.copyWith(currentPageIndex: state.currentPageIndex + 1));
    }
  }

  void _onPreviousPage(PreviousPage event, Emitter<OnboardingState> emit) {
    if (state.currentPageIndex > 0) {
      emit(state.copyWith(currentPageIndex: state.currentPageIndex - 1));
    }
  }
}
