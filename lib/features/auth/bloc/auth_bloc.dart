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
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(Unauthenticated());
  }

  Future<void> _onSendOtp(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1500));
    _currentPhoneNumber = event.phoneNumber;
    emit(OtpSentState(event.phoneNumber));
  }

  Future<void> _onVerifyOtp(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1500));
    if (event.code == '111111') {
      emit(AuthError("Wrong OTP entered. Please try again."));
      emit(OtpSentState(_currentPhoneNumber ?? "+91 9999999999"));
    } else {
      _tempUser = UserModel(
        id: 'usr_mock_otp',
        email: 'otp_user@doom.com',
        name: 'New Streamer',
        isSubscribed: false,
        subscriptionTier: 'Free',
      );
      emit(ProfileSetupRequiredState(_tempUser!));
    }
  }

  Future<void> _onEmailAuth(
    EmailAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1500));
    _tempUser = UserModel(
      id: 'usr_mock_email',
      email: event.email,
      name: event.email.split('@').first.toUpperCase(),
      isSubscribed: false,
      subscriptionTier: 'Free',
    );
    if (event.isSignUp) {
      emit(ProfileSetupRequiredState(_tempUser!));
    } else {
      emit(Authenticated(_tempUser!));
    }
  }

  Future<void> _onProfileSetup(
    ProfileSetupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_tempUser != null) {
      final updatedUser = _tempUser!.copyWith(
        name: event.name,
        // We will store the avatar index in profilePicture slot as a string ID
        profilePicture: event.avatarIndex.toString(),
        isSubscribed: false,
        subscriptionTier: 'Free',
      );
      emit(Authenticated(updatedUser));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 800));
    _tempUser = null;
    emit(Unauthenticated());
  }
}
