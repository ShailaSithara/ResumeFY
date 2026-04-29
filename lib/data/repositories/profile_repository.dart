// lib/data/repositories/profile_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/experience_model.dart';
import '../models/education_model.dart';

class ProfileRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection('users');

  // ✅ PRIVATE (only used inside this file)
  DocumentReference _userDoc(String uid) => _users.doc(uid);

  /// ✅ NEW: Save full profile (used in onboarding)
  Future<void> saveUserProfile(String uid, UserProfile profile) async {
    await _userDoc(uid).set(profile.toFirestore());
  }

  /// Create initial profile after signup
  Future<void> createProfile(String uid, PersonalDetails personal) async {
    final profile = UserProfile(
      uid: uid,
      personal: personal,
      createdAt: DateTime.now(),
    );
    await _userDoc(uid).set(profile.toFirestore());
  }

  /// Get profile as stream (real-time updates)
  Stream<UserProfile?> profileStream(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  /// Get profile once
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Update personal details
  Future<void> updatePersonal(String uid, PersonalDetails personal) async {
    await _userDoc(uid).update({
      'personal': personal.toMap(),
      'meta.updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update skills
  Future<void> updateSkills(String uid, List<String> skills) async {
    await _userDoc(uid).update({
      'skills': skills,
      'meta.updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update experience list
  Future<void> updateExperience(
      String uid, List<ExperienceModel> experience) async {
    await _userDoc(uid).update({
      'experience': experience.map((e) => e.toMap()).toList(),
      'meta.updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update education list
  Future<void> updateEducation(
      String uid, List<EducationModel> education) async {
    await _userDoc(uid).update({
      'education': education.map((e) => e.toMap()).toList(),
      'meta.updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update goals
  Future<void> updateGoals(String uid, GoalsData goals) async {
    await _userDoc(uid).update({
      'goals': goals.toMap(),
      'meta.updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePhotoUrl(String uid, String url) {
    return _userDoc(uid).update({
      'personal.photoUrl': url,
      'meta.updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark onboarding complete
  Future<void> completeOnboarding(String uid) async {
    await _userDoc(uid).update({
      'meta.onboardingComplete': true,
      'meta.updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete profile
  Future<void> deleteProfile(String uid) async {
    await _userDoc(uid).delete();
  }
}
