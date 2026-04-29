// lib/data/models/experience_model.dart

class ExperienceModel {
  final String id;
  final String role;
  final String company;
  final String startDate;
  final String? endDate;
  final bool isCurrent;
  final String description;

  const ExperienceModel({
    required this.id,
    required this.role,
    required this.company,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description = '',
  });

  factory ExperienceModel.fromMap(Map<String, dynamic> map) => ExperienceModel(
        id: map['id'] ?? '',
        role: map['role'] ?? '',
        company: map['company'] ?? '',
        startDate: map['startDate'] ?? '',
        endDate: map['endDate'],
        isCurrent: map['isCurrent'] ?? false,
        description: map['description'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'role': role,
        'company': company,
        'startDate': startDate,
        'endDate': endDate,
        'isCurrent': isCurrent,
        'description': description,
      };

  ExperienceModel copyWith({
    String? role,
    String? company,
    String? startDate,
    String? endDate,
    bool? isCurrent,
    String? description,
  }) =>
      ExperienceModel(
        id: id,
        role: role ?? this.role,
        company: company ?? this.company,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        isCurrent: isCurrent ?? this.isCurrent,
        description: description ?? this.description,
      );
}
