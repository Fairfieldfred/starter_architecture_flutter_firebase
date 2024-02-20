import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_repository.g.dart';

class OnboardingRepository {
  OnboardingRepository(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  static const onboardingCompleteKey = 'onboardingComplete';
  static const unlockImagePredictorKey = 'imagePredictorKey';

  Future<void> setOnboardingComplete() async {
    await sharedPreferences.setBool(onboardingCompleteKey, true);
  }

  Future<void> setUnlockingComplete() async {
    await sharedPreferences.setBool(unlockImagePredictorKey, true);
  }

  bool isOnboardingComplete() =>
      sharedPreferences.getBool(onboardingCompleteKey) ?? false;

  bool isImagePredictorUnlocked() =>
      sharedPreferences.getBool(unlockImagePredictorKey) ?? false;
}

@Riverpod(keepAlive: true)
Future<OnboardingRepository> onboardingRepository(
    OnboardingRepositoryRef ref) async {
  return OnboardingRepository(await SharedPreferences.getInstance());
}
