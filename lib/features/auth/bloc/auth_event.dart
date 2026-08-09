import '../../../data/models/user_model.dart';

abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;
  SendOtpRequested(this.phoneNumber);
}

class VerifyOtpRequested extends AuthEvent {
  final String code;
  VerifyOtpRequested(this.code);
}

class EmailAuthRequested extends AuthEvent {
  final String email;
  final String password;
  final bool isSignUp;
  EmailAuthRequested({
    required this.email,
    required this.password,
    required this.isSignUp,
  });
}

class ProfileSetupRequested extends AuthEvent {
  final String name;
  final int avatarIndex;
  ProfileSetupRequested({required this.name, required this.avatarIndex});
}

class LogoutRequested extends AuthEvent {}

class UpgradeRequested extends AuthEvent {
  final String tier;
  UpgradeRequested({required this.tier});
}

class RefreshUserRequested extends AuthEvent {}

class SessionRestored extends AuthEvent {
  final UserModel user;
  SessionRestored(this.user);
}
