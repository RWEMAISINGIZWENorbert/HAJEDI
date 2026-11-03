import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:hajedi/repository/auth_repository.dart';
import 'package:hajedi/utils/auth_utils.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(LoginLoading());
    try {
      await authRepository.login(
        name: event.name,
        password: event.password,
      );

      emit(
        LoginSuccessfully(
          message: 'Login successful',
        ),
      );
    } catch (error) {
      emit(
        LoginFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await AuthUtils.clearAuthData();

      emit(
        LogoutSuccessfully(
          message: 'Logout successful',
        ),
      );
    } catch (error) {
      emit(
        LogoutFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}