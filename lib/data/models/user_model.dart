// lib/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'experience_model.dart';
import 'education_model.dart';

class PersonalDetails {
  final String name;
  final String email;
  final String phone;
  final String headline;
  final String? photoUrl;

  const PersonalDetails({
    required this.name,
    required this.email,
    this.phone = '',
    this.headline = '',
    this.photoUrl,
  });

  factory PersonalDetails.fromMap(Map<String, dynamic> map) => PersonalDetails(
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        headline: map['headline'] ?? '',
        photoUrl: map['photoUrl'],
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'headline': headline,
        'photoUrl': photoUrl,
      };

  PersonalDetails copyWith({
    String? name,
    String? email,
    String? phone,
    String? headline,
    String? photoUrl,
  }) =>
      PersonalDetails(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        headline: headline ?? this.headline,
        photoUrl: photoUrl ?? this.photoUrl,
      );
}

class GoalsData {
  final List<String> interests;
  final String careerGoal;
  final String bio;

  const GoalsData({
    this.interests = const [],
    this.careerGoal = '',
    this.bio = '',
  });

  factory GoalsData.fromMap(Map<String, dynamic> map) => GoalsData(
        interests: List<String>.from(map['interests'] ?? []),
        careerGoal: map['careerGoal'] ?? '',
        bio: map['bio'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'interests': interests,
        'careerGoal': careerGoal,
        'bio': bio,
      };

  GoalsData copyWith({
    List<String>? interests,
    String? careerGoal,
    String? bio,
  }) =>
      GoalsData(
        interests: interests ?? this.interests,
        careerGoal: careerGoal ?? this.careerGoal,
        bio: bio ?? this.bio,
      );
}

class UserProfile {
  final String uid;
  final PersonalDetails personal;
  final List<String> skills;
  final List<ExperienceModel> experience;
  final List<EducationModel> education;
  final GoalsData goals;
  final bool onboardingComplete;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.personal,
    this.skills = const [],
    this.experience = const [],
    this.education = const [],
    this.goals = const GoalsData(),
    this.onboardingComplete = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      personal: PersonalDetails.fromMap(data['personal'] ?? {}),
      skills: List<String>.from(data['skills'] ?? []),
      experience: (data['experience'] as List<dynamic>? ?? [])
          .map((e) => ExperienceModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      education: (data['education'] as List<dynamic>? ?? [])
          .map((e) => EducationModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      goals: GoalsData.fromMap(data['goals'] ?? {}),
      onboardingComplete: data['meta']?['onboardingComplete'] ?? false,
      createdAt: (data['meta']?['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['meta']?['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'personal': personal.toMap(),
        'skills': skills,
        'experience': experience.map((e) => e.toMap()).toList(),
        'education': education.map((e) => e.toMap()).toList(),
        'goals': goals.toMap(),
        'meta': {
          'onboardingComplete': onboardingComplete,
          'createdAt': createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      };

  UserProfile copyWith({
    PersonalDetails? personal,
    List<String>? skills,
    List<ExperienceModel>? experience,
    List<EducationModel>? education,
    GoalsData? goals,
    bool? onboardingComplete,
  }) =>
      UserProfile(
        uid: uid,
        personal: personal ?? this.personal,
        skills: skills ?? this.skills,
        experience: experience ?? this.experience,
        education: education ?? this.education,
        goals: goals ?? this.goals,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
