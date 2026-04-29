// lib/providers/onboarding_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/models/experience_model.dart';
import '../data/models/education_model.dart';
import '../data/repositories/profile_repository.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// === STATE ===
class OnboardingState {
  final int currentStep;
  final PersonalDetails personal;
  final List<String> skills;
  final List<ExperienceModel> experience;
  final List<EducationModel> education;
  final GoalsData goals;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.currentStep = 0,
    this.personal = const PersonalDetails(name: '', email: ''),
    this.skills = const [],
    this.experience = const [],
    this.education = const [],
    this.goals = const GoalsData(),
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    int? currentStep,
    PersonalDetails? personal,
    List<String>? skills,
    List<ExperienceModel>? experience,
    List<EducationModel>? education,
    GoalsData? goals,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      personal: personal ?? this.personal,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error, // ✅ FIXED
    );
  }
}

// === NOTIFIER ===
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final ProfileRepository _repo;
  final String uid;

  OnboardingNotifier(this._repo, this.uid) : super(const OnboardingState());

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) => state = state.copyWith(currentStep: step);

  // STEP 1
  void updatePersonal(PersonalDetails personal) {
    state = state.copyWith(personal: personal);
  }

  // STEP 2
  void addSkill(String skill) {
    if (!state.skills.contains(skill) && skill.isNotEmpty) {
      state = state.copyWith(skills: [...state.skills, skill]);
    }
  }

  void removeSkill(String skill) {
    state = state.copyWith(
      skills: state.skills.where((s) => s != skill).toList(),
    );
  }

  // STEP 3
  void addExperience(ExperienceModel exp) {
    final newExp = ExperienceModel(
      id: _uuid.v4(),
      role: exp.role,
      company: exp.company,
      startDate: exp.startDate,
      endDate: exp.endDate,
      isCurrent: exp.isCurrent,
      description: exp.description,
    );

    state = state.copyWith(
      experience: [...state.experience, newExp],
    );
  }

  void removeExperience(String id) {
    state = state.copyWith(
      experience: state.experience.where((e) => e.id != id).toList(),
    );
  }

  // STEP 4
  void addEducation(EducationModel edu) {
    final newEdu = EducationModel(
      id: _uuid.v4(),
      degree: edu.degree,
      institution: edu.institution,
      field: edu.field,
      startYear: edu.startYear,
      endYear: edu.endYear,
      grade: edu.grade,
    );

    state = state.copyWith(
      education: [...state.education, newEdu],
    );
  }

  void removeEducation(String id) {
    state = state.copyWith(
      education: state.education.where((e) => e.id != id).toList(),
    );
  }

  // STEP 5
  void updateGoals(GoalsData goals) {
    state = state.copyWith(goals: goals);
  }

  // ✅ FINAL SAVE
  Future<bool> saveAll() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final profile = UserProfile(
        uid: uid,
        personal: state.personal,
        skills: state.skills,
        experience: state.experience,
        education: state.education,
        goals: state.goals,
        onboardingComplete: true,
        createdAt: DateTime.now(),
      );

      await _repo.saveUserProfile(uid, profile);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

// === PROVIDERS ===
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final onboardingProvider =
    StateNotifierProvider.family<OnboardingNotifier, OnboardingState, String>(
  (ref, uid) => OnboardingNotifier(
    ref.watch(profileRepositoryProvider),
    uid,
  ),
);
