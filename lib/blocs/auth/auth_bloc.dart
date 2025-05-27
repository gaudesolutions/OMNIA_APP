// lib/blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/blocs/auth/auth_event.dart';
import 'package:medical_app/blocs/auth/auth_state.dart';
import 'package:medical_app/data/repositories/auth_repository.dart';
import 'package:medical_app/data/repositories/user_repository.dart';
import 'package:medical_app/data/models/user.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthBloc({
    required this.authRepository,
    required this.userRepository,
  }) : super(AuthInitial()) {
    on<AuthCheckStatus>(_onAuthCheckStatus);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

Future<void> _onAuthCheckStatus(
  AuthCheckStatus event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());
  try {
    final user = await userRepository.getUser();
    print('User from repository: ${user?.name ?? "No name"}');
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  } catch (e) {
    print('Auth check error: $e');
    emit(AuthUnauthenticated());
  }
}

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.username, event.password);
      if (user != null) {
        await userRepository.saveUser(user);
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthFailure('Invalid username or password'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(
        name: event.name,
        username: event.username,
        email: event.email,
        password: event.password,
        role: event.role,
      );
      if (user != null) {
        await userRepository.saveUser(user);
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthFailure('Registration failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      await userRepository.deleteUser();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
