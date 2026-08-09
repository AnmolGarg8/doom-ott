import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  String? _currentPhoneNumber;
  UserModel? _tempUser;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SendOtpRequested>(_onSendOtp);
    on<VerifyOtpRequested>(_onVerifyOtp);
    on<EmailAuthRequested>(_onEmailAuth);
    on<ProfileSetupRequested>(_onProfileSetup);
    on<LogoutRequested>(_onLogout);
    on<RefreshUserRequested>(_onRefreshUser);
    on<SessionRestored>(_onSessionRestored);
  }

  void _onSessionRestored(
    SessionRestored event,
    Emitter<AuthState> emit,
  ) {
    _tempUser = event.user;
    emit(Authenticated(event.user));
  }

  Future<void> _onRefreshUser(
    RefreshUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      }
    } catch (_) {}
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSendOtp(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.sendOtp(event.phoneNumber);
      _currentPhoneNumber = event.phoneNumber;
      emit(OtpSentState(event.phoneNumber));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final phone = _currentPhoneNumber ?? "+19876543210";
      final user = await authRepository.verifyOtp(phone, event.code);
      _tempUser = user;
      emit(Authenticated(user));
    } on ProfileSetupRequiredException catch (e) {
      _tempUser = e.user;
      emit(ProfileSetupRequiredState(e.user));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
      if (_currentPhoneNumber != null) {
        emit(OtpSentState(_currentPhoneNumber!));
      }
    }
  }

  Future<void> _onEmailAuth(
    EmailAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final UserModel user;
      if (event.isSignUp) {
        final name = event.email.split('@').first;
        user = await authRepository.signUpWithEmail(
          name,
          event.email,
          event.password,
        );
      } else {
        user = await authRepository.loginWithEmail(event.email, event.password);
      }
      _tempUser = user;
      emit(Authenticated(user));
    } on ProfileSetupRequiredException catch (e) {
      _tempUser = e.user;
      emit(ProfileSetupRequiredState(e.user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onProfileSetup(
    ProfileSetupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final avatarKey = 'avatar_${event.avatarIndex}';
      await authRepository.createProfile(event.name, avatarKey, false);

      if (_tempUser != null) {
        final updatedUser = _tempUser!.copyWith(
          name: event.name,
          profilePicture: event.avatarIndex.toString(),
        );
        emit(Authenticated(updatedUser));
      } else {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
    } catch (_) {}
    _tempUser = null;
    emit(Unauthenticated());
  }
}
