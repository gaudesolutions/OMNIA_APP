import 'package:equatable/equatable.dart';
import 'package:medical_app/data/models/user.dart';
// import 'package:your_app/data/models/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class FetchUsersEvent extends UserEvent {
  final String? searchQuery;
  
  const FetchUsersEvent({this.searchQuery});
  
  @override
  List<Object?> get props => [searchQuery];
}

class FetchUserStatsEvent extends UserEvent {}

class FetchUsersByClinicEvent extends UserEvent {}

class AddUserEvent extends UserEvent {
  final User1 user;
  final String password;

  const AddUserEvent({required this.user, required this.password});

  @override
  List<Object?> get props => [user, password];
}

class UpdateUserEvent extends UserEvent {
  final User1 user;
  final String? password;

  const UpdateUserEvent({required this.user, this.password});

  @override
  List<Object?> get props => [user, password];
}

class DeleteUserEvent extends UserEvent {
  final int userId;

  const DeleteUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
