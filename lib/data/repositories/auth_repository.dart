import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> logout();
  Future<UserModel> upgradeSubscription(String tier);
}

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _currentUser;
  }

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    _currentUser = UserModel(
      id: 'usr_1',
      email: email,
      name: email.split('@').first.toUpperCase(),
      isSubscribed: false,
      subscriptionTier: 'Free',
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('All fields are required');
    }
    _currentUser = UserModel(
      id: 'usr_2',
      email: email,
      name: name,
      isSubscribed: false,
      subscriptionTier: 'Free',
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<UserModel> upgradeSubscription(String tier) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }
    _currentUser = _currentUser!.copyWith(
      isSubscribed: tier != 'Free',
      subscriptionTier: tier,
    );
    return _currentUser!;
  }
}
