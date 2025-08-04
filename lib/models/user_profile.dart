import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final int age;
  final String country;
  final String? profilePhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.age,
    required this.country,
    this.profilePhotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Firestore'dan veri oluşturma
  factory UserProfile.fromFirestore(Map<String, dynamic> data, String id) {
    return UserProfile(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'] ?? '',
      age: data['age'] ?? 0,
      country: data['country'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Firestore'a veri gönderme
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'age': age,
      'country': country,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Kopyalama metodu
  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    int? age,
    String? country,
    String? profilePhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      country: country ?? this.country,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Tam ad getter'ı
  String get fullName => '$firstName $lastName';

  // Yaş grubu getter'ı
  String get ageGroup {
    if (age < 18) return '18 yaş altı';
    if (age < 25) return '18-24';
    if (age < 35) return '25-34';
    if (age < 45) return '35-44';
    if (age < 55) return '45-54';
    if (age < 65) return '55-64';
    return '65+';
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, firstName: $firstName, lastName: $lastName, email: $email, gender: $gender, age: $age, country: $country)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 