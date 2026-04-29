// lib/providers/profile_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/models/experience_model.dart';
import '../data/models/education_model.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/storage_repository.dart';
import 'auth_provider.dart';
import 'onboarding_provider.dart';

/// Real-time profile stream for the current user
final profileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  final repo = ref.watch(profileRepositoryProvider);
  return repo.profileStream(user.uid);
});

/// Profile actions (including photo upload)
class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repo;
  final StorageRepository _storage;
  final String uid;

  ProfileNotifier(this._repo, this._storage, this.uid)
      : super(const AsyncData(null));

  Future<void> updatePersonal(PersonalDetails personal) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.updatePersonal(uid, personal));
  }

  /// Uploads [imageFile] to Firebase Storage, then saves the download URL
  /// to the user's Firestore document (personal.photoUrl).
  Future<String?> uploadAndSetPhoto(File imageFile) async {
    state = const AsyncLoading();
    try {
      final url = await _storage.uploadProfilePhoto(uid: uid, file: imageFile);
      await _repo.updatePhotoUrl(uid, url);
      state = const AsyncData(null);
      return url;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> removePhoto() async {
    state = const AsyncLoading();
    try {
      await _storage.deleteProfilePhoto(uid);
      await _repo.updatePhotoUrl(uid, '');
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateSkills(List<String> skills) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.updateSkills(uid, skills));
  }

  Future<void> updateExperience(List<ExperienceModel> experience) async {
    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => _repo.updateExperience(uid, experience));
  }

  Future<void> updateEducation(List<EducationModel> education) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.updateEducation(uid, education));
  }

  Future<void> updateGoals(GoalsData goals) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.updateGoals(uid, goals));
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<void>>((ref) {
  final user = ref.watch(currentUserProvider);
  return ProfileNotifier(
    ref.watch(profileRepositoryProvider),
    ref.watch(storageRepositoryProvider),
    user?.uid ?? '',
  );
});
