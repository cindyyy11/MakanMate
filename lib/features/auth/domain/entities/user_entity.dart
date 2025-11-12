import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String role;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    role,
    displayName,
    photoUrl,
    isAnonymous,
  ];
}
