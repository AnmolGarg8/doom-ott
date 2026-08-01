import '../../../data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {
  final String phoneNumber;
  OtpSentState(this.phoneNumber);
}

class ProfileSetupRequiredState extends AuthState {
  final UserModel user;
  ProfileSetupRequiredState(this.user);
}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
