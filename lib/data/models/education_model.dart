// lib/data/models/education_model.dart

class EducationModel {
  final String id;
  final String degree;
  final String institution;
  final String field;
  final String startYear;
  final String endYear;
  final String grade;

  const EducationModel({
    required this.id,
    required this.degree,
    required this.institution,
    required this.field,
    required this.startYear,
    required this.endYear,
    this.grade = '',
  });

  factory EducationModel.fromMap(Map<String, dynamic> map) => EducationModel(
        id: map['id'] ?? '',
        degree: map['degree'] ?? '',
        institution: map['institution'] ?? '',
        field: map['field'] ?? '',
        startYear: map['startYear'] ?? '',
        endYear: map['endYear'] ?? '',
        grade: map['grade'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'degree': degree,
        'institution': institution,
        'field': field,
        'startYear': startYear,
        'endYear': endYear,
        'grade': grade,
      };

  EducationModel copyWith({
    String? degree,
    String? institution,
    String? field,
    String? startYear,
    String? endYear,
    String? grade,
  }) =>
      EducationModel(
        id: id,
        degree: degree ?? this.degree,
        institution: institution ?? this.institution,
        field: field ?? this.field,
        startYear: startYear ?? this.startYear,
        endYear: endYear ?? this.endYear,
        grade: grade ?? this.grade,
      );
}
