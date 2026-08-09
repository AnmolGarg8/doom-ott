import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';

class ProfileSetupRequiredException implements Exception {
  final UserModel user;
  ProfileSetupRequiredException(this.user);
}

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<void> sendOtp(String phone);
  Future<UserModel> verifyOtp(String phone, String otp);
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String name, String email, String password);
  Future<UserModel> loginWithGoogle(String token);
  Future<UserModel> loginWithApple(String token);
  Future<void> logout();
  Future<UserModel> upgradeSubscription(String tier);
  Future<Map<String, dynamic>> createProfile(
    String name,
    String avatarKey,
    bool isKids,
  );
  Future<Map<String, dynamic>> updateProfile(
    String profileId,
    String name,
    String avatarKey,
    bool isKids,
  );
  Future<void> deleteProfile(String profileId);

  // Backward compatibility
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
}

class RealAuthRepository implements AuthRepository {
  final DioClient dioClient;

  RealAuthRepository({required this.dioClient});

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await dioClient.storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      return null;
    }
    try {
      final response = await dioClient.get('/auth/me');
      if (response.statusCode == 200 && response.data != null) {
        final userData = Map<String, dynamic>.from(response.data as Map);

        bool isSubscribed = false;
        String subscriptionTier = 'Free';

        try {
          final subResponse = await dioClient.get('/subscription/current');
          if (subResponse.statusCode == 200 && subResponse.data != null) {
            final subData = Map<String, dynamic>.from(subResponse.data as Map);
            final status = subData['status'] as String?;
            if (status == 'ACTIVE' || status == 'active') {
              isSubscribed = true;
              final plan = subData['plan'] != null
                  ? Map<String, dynamic>.from(subData['plan'] as Map)
                  : null;
              if (plan != null) {
                subscriptionTier = plan['name'] as String? ?? 'Premium';
              }
            }
          }
        } catch (_) {}

        userData['is_subscribed'] = isSubscribed;
        userData['subscription_tier'] = subscriptionTier;

        final user = UserModel.fromJson(userData);
        await dioClient.storage.write(
          key: 'user_data',
          value: jsonEncode(user.toJson()),
        );

        // Fetch and sync profiles from GET /users/me
        try {
          final meResponse = await dioClient.get('/users/me');
          if (meResponse.statusCode == 200 && meResponse.data != null) {
            final meData = Map<String, dynamic>.from(meResponse.data as Map);
            final profilesList = meData['profiles'] as List? ?? [];
            final profileBox = await Hive.openBox<dynamic>('user_profiles');

            final String? currentActiveId =
                profileBox.get('active_id') as String?;

            await profileBox.clear();

            String? newActiveId;
            for (final p in profilesList) {
              final profileMap = Map<String, dynamic>.from(p as Map);
              final pId = profileMap['id'] as String;
              final pName = profileMap['name'] as String;
              final avatarKey =
                  profileMap['avatar_key'] as String? ?? 'avatar_1';
              final isKids = profileMap['is_kids_profile'] as bool? ?? false;

              int avatarIndex = 0;
              final match = RegExp(r'\d+').firstMatch(avatarKey);
              if (match != null) {
                avatarIndex = int.parse(match.group(0)!);
              }

              await profileBox.put(pId, {
                'id': pId,
                'name': pName,
                'avatarIndex': avatarIndex,
                'isKids': isKids,
              });

              if (pId == currentActiveId) {
                newActiveId = pId;
              }
            }

            if (newActiveId == null && profilesList.isNotEmpty) {
              newActiveId = Map<String, dynamic>.from(
                profilesList.first as Map,
              )['id'] as String;
            }

            if (newActiveId != null) {
              await profileBox.put('active_id', newActiveId);
            }
          }
        } catch (_) {}

        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> sendOtp(String phone) async {
    try {
      final response = await dioClient.post(
        '/auth/otp/send',
        data: {'phone': phone},
      );
      if (response.statusCode != 200) {
        final detail = response.data is Map
            ? response.data['detail']
            : 'Failed to send OTP';
        throw Exception(detail);
      }
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? e.response?.data['detail']
          : e.message;
      throw Exception(detail ?? 'Failed to send OTP');
    }
  }

  @override
  Future<UserModel> verifyOtp(String phone, String otp) async {
    try {
      final response = await dioClient.post(
        '/auth/otp/verify',
        data: {'phone': phone, 'otp': otp},
      );
      return await _handleTokenResponse(response);
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? e.response?.data['detail']
          : e.message;
      throw Exception(detail ?? 'Invalid OTP code');
    }
  }

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final response = await dioClient.post(
        '/auth/email/login',
        data: {'email': email, 'password': password},
      );
      return await _handleTokenResponse(response);
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? e.response?.data['detail']
          : e.message;
      throw Exception(detail ?? 'Login failed');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await dioClient.post(
        '/auth/email/signup',
        data: {'name': name, 'email': email, 'password': password},
      );
      return await _handleTokenResponse(response);
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? e.response?.data['detail']
          : e.message;
      throw Exception(detail ?? 'Sign up failed');
    }
  }

  @override
  Future<UserModel> loginWithGoogle(String token) async {
    try {
      final response = await dioClient.post(
        '/auth/social/google',
        data: {'token': token},
      );
      return await _handleTokenResponse(response);
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? e.response?.data['detail']
          : e.message;
      throw Exception(detail ?? 'Google authentication failed');
    }
  }

  @override
  Future<UserModel> loginWithApple(String token) async {
    try {
      final response = await dioClient.post(
        '/auth/social/apple',
        data: {'token': token},
      );
      return await _handleTokenResponse(response);
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? e.response?.data['detail']
          : e.message;
      throw Exception(detail ?? 'Apple authentication failed');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post('/auth/logout');
    } catch (_) {}
    await dioClient.storage.deleteAll();
  }

  @override
  Future<UserModel> upgradeSubscription(String tier) async {
    final user = await getCurrentUser();
    if (user == null) throw Exception('No user logged in');
    final updated = user.copyWith(isSubscribed: true, subscriptionTier: tier);
    await dioClient.storage.write(
      key: 'user_data',
      value: jsonEncode(updated.toJson()),
    );
    return updated;
  }

  @override
  Future<UserModel> login(String email, String password) =>
      loginWithEmail(email, password);

  @override
  Future<UserModel> register(String name, String email, String password) =>
      signUpWithEmail(name, email, password);

  Future<UserModel> _handleTokenResponse(Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;

      await dioClient.storage.write(key: 'access_token', value: accessToken);
      await dioClient.storage.write(key: 'refresh_token', value: refreshToken);

      final user = await getCurrentUser();
      if (user != null) {
        final profileBox = await Hive.openBox<dynamic>('user_profiles');
        final keys = profileBox.keys.where((k) => k != 'active_id').toList();
        if (keys.isEmpty) {
          throw ProfileSetupRequiredException(user);
        }
        return user;
      }
      throw Exception('Failed to retrieve user profile after authentication');
    }
    throw Exception('Authentication failed');
  }

  @override
  Future<Map<String, dynamic>> createProfile(
    String name,
    String avatarKey,
    bool isKids,
  ) async {
    try {
      final response = await dioClient.post(
        '/users/profiles',
        data: {
          'name': name,
          'avatar_key': avatarKey,
          'is_kids_profile': isKids,
        },
      );
      if (response.statusCode == 201 && response.data != null) {
        final data = Map<String, dynamic>.from(response.data as Map);

        final profileBox = await Hive.openBox<dynamic>('user_profiles');
        final pId = data['id'] as String;
        final pName = data['name'] as String;
        final key = data['avatar_key'] as String;
        final isKidsProfile = data['is_kids_profile'] as bool? ?? false;

        int avatarIndex = 0;
        final match = RegExp(r'\d+').firstMatch(key);
        if (match != null) {
          avatarIndex = int.parse(match.group(0)!);
        }

        await profileBox.put(pId, {
          'id': pId,
          'name': pName,
          'avatarIndex': avatarIndex,
          'isKids': isKidsProfile,
        });

        await profileBox.put('active_id', pId);

        return data;
      }
      throw Exception('Failed to create profile');
    } on DioException catch (e) {
      final detail =
          e.response?.data is Map ? e.response?.data['detail'] : e.message;
      throw Exception(detail ?? 'Failed to create profile');
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile(
    String profileId,
    String name,
    String avatarKey,
    bool isKids,
  ) async {
    try {
      final response = await dioClient.dio.patch(
        '/users/profiles/$profileId',
        data: {
          'name': name,
          'avatar_key': avatarKey,
          'is_kids_profile': isKids,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = Map<String, dynamic>.from(response.data as Map);

        final profileBox = await Hive.openBox<dynamic>('user_profiles');
        final pId = data['id'] as String;
        final pName = data['name'] as String;
        final key = data['avatar_key'] as String;
        final isKidsProfile = data['is_kids_profile'] as bool? ?? false;

        int avatarIndex = 0;
        final match = RegExp(r'\d+').firstMatch(key);
        if (match != null) {
          avatarIndex = int.parse(match.group(0)!);
        }

        await profileBox.put(pId, {
          'id': pId,
          'name': pName,
          'avatarIndex': avatarIndex,
          'isKids': isKidsProfile,
        });

        return data;
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      final detail =
          e.response?.data is Map ? e.response?.data['detail'] : e.message;
      throw Exception(detail ?? 'Failed to update profile');
    }
  }

  @override
  Future<void> deleteProfile(String profileId) async {
    try {
      final response = await dioClient.dio.delete('/users/profiles/$profileId');
      if (response.statusCode == 204 || response.statusCode == 200) {
        final profileBox = await Hive.openBox<dynamic>('user_profiles');
        await profileBox.delete(profileId);

        final activeId = profileBox.get('active_id') as String?;
        if (activeId == profileId) {
          final keys = profileBox.keys.where((k) => k != 'active_id').toList();
          if (keys.isNotEmpty) {
            await profileBox.put('active_id', keys.first as String);
          } else {
            await profileBox.delete('active_id');
          }
        }
        return;
      }
      throw Exception('Failed to delete profile');
    } on DioException catch (e) {
      final detail =
          e.response?.data is Map ? e.response?.data['detail'] : e.message;
      throw Exception(detail ?? 'Failed to delete profile');
    }
  }
}

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _currentUser;
  }

  @override
  Future<void> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<UserModel> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _currentUser = UserModel(
      id: 'usr_mock_otp',
      phone: phone,
      email: 'otp_user@doom.com',
      name: 'Streamer',
      isSubscribed: false,
      subscriptionTier: 'Free',
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    return login(email, password);
  }

  @override
  Future<UserModel> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    return register(name, email, password);
  }

  @override
  Future<UserModel> loginWithGoogle(String token) async {
    _currentUser = UserModel(
      id: 'usr_google',
      email: 'google_user@doom.com',
      name: 'Google Streamer',
      isSubscribed: false,
      subscriptionTier: 'Free',
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> loginWithApple(String token) async {
    _currentUser = UserModel(
      id: 'usr_apple',
      email: 'apple_user@doom.com',
      name: 'Apple Streamer',
      isSubscribed: false,
      subscriptionTier: 'Free',
    );
    return _currentUser!;
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

  @override
  Future<Map<String, dynamic>> createProfile(
    String name,
    String avatarKey,
    bool isKids,
  ) async {
    return {
      'id': 'p_mock',
      'name': name,
      'avatar_key': avatarKey,
      'is_kids_profile': isKids,
    };
  }

  @override
  Future<Map<String, dynamic>> updateProfile(
    String profileId,
    String name,
    String avatarKey,
    bool isKids,
  ) async {
    return {
      'id': profileId,
      'name': name,
      'avatar_key': avatarKey,
      'is_kids_profile': isKids,
    };
  }

  @override
  Future<void> deleteProfile(String profileId) async {}
}
