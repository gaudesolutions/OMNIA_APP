import 'package:equatable/equatable.dart';
import 'package:medical_app/data/models/user.dart';


enum UserStatus { initial, loading, success, failure }

class UserState extends Equatable {
  final UserStatus status;
  final List<User1> users;
  final UserStatistics? statistics;
  final List<ClinicUserCount>? clinicUsers;
  final String? errorMessage;
  final String? searchQuery;

  const UserState({
    required this.status,
    required this.users,
    this.statistics,
    this.clinicUsers,
    this.errorMessage,
    this.searchQuery,
  });

  factory UserState.initial() {
    return const UserState(
      status: UserStatus.initial,
      users: [],
    );
  }

  UserState copyWith({
    UserStatus? status,
    List<User1>? users,
    UserStatistics? statistics,
    List<ClinicUserCount>? clinicUsers,
    String? errorMessage,
    String? searchQuery,
  }) {
    return UserState(
      status: status ?? this.status,
      users: users ?? this.users,
      statistics: statistics ?? this.statistics,
      clinicUsers: clinicUsers ?? this.clinicUsers,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [status, users, statistics, clinicUsers, errorMessage, searchQuery];
}