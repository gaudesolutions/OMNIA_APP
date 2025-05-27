
// lib/bloc/user/user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service.dart';
// import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_event.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_state.dart';


class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;

  UserBloc(this.userService) : super(UserState.initial()) {
    on<FetchUsersEvent>(_onFetchUsers);
    on<FetchUserStatsEvent>(_onFetchUserStats);
    on<FetchUsersByClinicEvent>(_onFetchUsersByClinic);
    on<AddUserEvent>(_onAddUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onFetchUsers(FetchUsersEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(
      status: UserStatus.loading,
      searchQuery: event.searchQuery,
    ));
    
    try {
      final users = await userService.fetchUsers(search: event.searchQuery);
      emit(state.copyWith(
        status: UserStatus.success,
        users: users,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchUserStats(FetchUserStatsEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.loading));
    
    try {
      final stats = await userService.getUserStatistics();
      emit(state.copyWith(
        status: UserStatus.success,
        statistics: stats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchUsersByClinic(FetchUsersByClinicEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.loading));
    
    try {
      final clinicUsers = await userService.getUsersByClinic();
      emit(state.copyWith(
        status: UserStatus.success,
        clinicUsers: clinicUsers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
// In user_bloc.dart - Enhance the _onAddUser method with better debugging:
Future<void> _onAddUser(AddUserEvent event, Emitter<UserState> emit) async {
  print("Starting _onAddUser process");
  emit(state.copyWith(status: UserStatus.loading));
  try {
    print("Creating user in service");
    await userService.createUser(event.user, event.password);
    print("User created successfully, fetching updated list");
    
    // Force a short delay to ensure backend processing
    await Future.delayed(const Duration(milliseconds: 200));
    
    final updatedUsers = await userService.fetchUsers();
    print("Fetched ${updatedUsers.length} users after creation");
    
    emit(state.copyWith(
      status: UserStatus.success,
      users: updatedUsers,
    ));
    print("Emitted success state with updated users");
  } catch (e) {
    print("Error in _onAddUser: ${e.toString()}");
    emit(state.copyWith(
      status: UserStatus.failure,
      errorMessage: e.toString(),
    ));
  }
}


  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.loading));
    
    try {
      final updatedUser = await userService.updateUser(event.user, password: event.password);
      final updatedUsers = state.users.map((user) {
        return user.id == updatedUser.id ? updatedUser : user;
      }).toList();
      
      emit(state.copyWith(
        status: UserStatus.success,
        users: updatedUsers,
      ));

      print('User updated successfully: ${updatedUser}');
    } catch (e) {
      emit(state.copyWith(
        status: UserStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteUser(DeleteUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.loading));
    
    try {
      await userService.deleteUser(event.userId);
      final filteredUsers = state.users.where((user) => user.id != event.userId).toList();
      
      emit(state.copyWith(
        status: UserStatus.success,
        users: filteredUsers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
