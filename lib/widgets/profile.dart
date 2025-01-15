class Profile {
  final String id;
  final DateTime? updatedAt;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? school;
  final int? grade;
  final DateTime? dateOfBirth;
  final String? quintile;
  final bool isVerified;
  final String? profilePicture;
  final String? careerAsp1;
  final String? careerAsp2;
  final String? careerAsp3;
  final String? acadChal1;
  final String? acadChal2;
  final String? acadChal3;
  final String? learningMethod1;
  final String? learningMethod2;
  final String? learningMethod3;
  final String? race;
  final String? gender;
  final String? hobby1;
  final String? hobby2;
  final String? hobby3;
  final String? nearbyAmenity;
  final String? safety;
  final String? importantFeature;
  final String? commute;
  final String? status;

  Profile({
    required this.id,
    this.updatedAt,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.school,
    this.grade,
    this.dateOfBirth,
    this.quintile,
    required this.isVerified,
    this.profilePicture,
    this.careerAsp1,
    this.careerAsp2,
    this.careerAsp3,
    this.acadChal1,
    this.acadChal2,
    this.acadChal3,
    this.learningMethod1,
    this.learningMethod2,
    this.learningMethod3,
    this.race,
    this.gender,
    this.hobby1,
    this.hobby2,
    this.hobby3,
    this.nearbyAmenity,
    this.safety,
    this.importantFeature,
    this.commute,
    this.status,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number']?.toString(),
      school: json['school'],
      grade: json['grade'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      quintile: json['quintile'],
      isVerified: json['is_verified'] ?? false,
      profilePicture: json['profile_picture'],
      careerAsp1: json['career_asp1'],
      careerAsp2: json['career_asp2'],
      careerAsp3: json['career_asp3'],
      acadChal1: json['acad_chal1'],
      acadChal2: json['acad_chal2'],
      acadChal3: json['acad_chal3'],
      learningMethod1: json['learning_method1'],
      learningMethod2: json['learning_method2'],
      learningMethod3: json['learning_method3'],
      race: json['race'],
      gender: json['gender'],
      hobby1: json['hobby1'],
      hobby2: json['hobby2'],
      hobby3: json['hobby3'],
      nearbyAmenity: json['nearby_amenity'],
      safety: json['safety'],
      importantFeature: json['important_feature'],
      commute: json['commute'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'updated_at': updatedAt?.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'school': school,
      'grade': grade,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'quintile': quintile,
      'is_verified': isVerified,
      'profile_picture': profilePicture,
      'career_asp1': careerAsp1,
      'career_asp2': careerAsp2,
      'career_asp3': careerAsp3,
      'acad_chal1': acadChal1,
      'acad_chal2': acadChal2,
      'acad_chal3': acadChal3,
      'learning_method1': learningMethod1,
      'learning_method2': learningMethod2,
      'learning_method3': learningMethod3,
      'race': race,
      'gender': gender,
      'hobby1': hobby1,
      'hobby2': hobby2,
      'hobby3': hobby3,
      'nearby_amenity': nearbyAmenity,
      'safety': safety,
      'important_feature': importantFeature,
      'commute': commute,
      'status': status,
    };
  }
}