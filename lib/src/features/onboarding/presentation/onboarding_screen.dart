import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/src/common_widgets/primary_button.dart';
import '/src/common_widgets/responsive_center.dart';
import '/src/features/onboarding/presentation/onboarding_controller.dart';
import '/src/localization/string_hardcoded.dart';
import '/src/routing/app_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final List<String> messages = [
    "Welcome to A Hole Meter",
    '',
    "This app is just for fun only.",
    '',
    "It uses an AI model of facial pics...",
    '',
    "to predict if an image depicts an asshole.",
    '',
    'Don${"'"}t take it too seriously.',
    ''
  ];
  int currentIndex = 0;
  late Timer _timer;
  bool isVisible = true;
  bool isStartButtonVisible = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    var counter = 8;
    _timer = Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      counter--;
      if (counter == 0) {
        timer.cancel();
        setState(() {
          isStartButtonVisible = !isStartButtonVisible;
        });
      }
      setState(() {
        currentIndex = (currentIndex + 1) % messages.length;
        isVisible = !isVisible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/glory_hole.png"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ResponsiveCenter(
          maxContentWidth: 450,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 1,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: isVisible ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      messages[currentIndex],
                      style:
                          const TextStyle(fontSize: 24.0, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              // SvgPicture.asset(
              //   'assets/time-tracking.svg',
              //   width: 200,
              //   height: 200,
              //   semanticsLabel: 'Time tracking logo',
              // ),
              Flexible(flex: 3, child: Container()),

              Flexible(
                flex: 1,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: isStartButtonVisible ? 1.0 : 0.0,
                  child: PrimaryButton(
                    text: 'Get Started'.hardcoded,
                    isLoading: state.isLoading,
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            await ref
                                .read(onboardingControllerProvider.notifier)
                                .completeOnboarding();
                            if (context.mounted) {
                              // go to sign in page after completing onboarding
                              if (isStartButtonVisible) {
                                context.goNamed(AppRoute.signIn.name);
                              }
                            }
                          },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
