import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../data/repositories/auth_repository.dart';

class ManageDevicesScreen extends StatefulWidget {
  const ManageDevicesScreen({super.key});

  @override
  State<ManageDevicesScreen> createState() => _ManageDevicesScreenState();
}

class _ManageDevicesScreenState extends State<ManageDevicesScreen> {
  List<dynamic> _activeSessions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = context.read<AuthRepository>();
      final sessions = await authRepo.getActiveSessions();
      setState(() {
        _activeSessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _logoutDevice(String sessionId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authRepo = context.read<AuthRepository>();
      await authRepo.deleteSession(sessionId);
      await _loadSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device logged out successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Manage Devices',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppThemeConstants.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Active Sessions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppThemeConstants.space8),
              Text(
                'These are the devices currently logged into your account. You can log out of any device remotely.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: AppThemeConstants.space24),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: AppThemeConstants.space16),
              ],
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : _activeSessions.isEmpty
                        ? const Center(
                            child: Text(
                              'No active devices found.',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _activeSessions.length,
                            separatorBuilder: (context, index) =>
                                const Divider(color: AppColors.surface, height: 1),
                            itemBuilder: (context, index) {
                              final session = _activeSessions[index];
                              final isCurrent =
                                  session['is_current'] as bool? ?? false;
                              final lastActive =
                                  session['last_active_at'] as String? ?? 'Unknown';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppThemeConstants.space12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      session['device_name']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains('phone') ||
                                              session['device_name']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains('pixel')
                                          ? LucideIcons.smartphone
                                          : LucideIcons.monitor,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: AppThemeConstants.space16,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session['device_name'] as String? ??
                                                'Device',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isCurrent
                                                ? 'Current Device'
                                                : 'Last active: $lastActive',
                                            style: TextStyle(
                                              color: isCurrent
                                                  ? AppColors.primary
                                                  : AppColors.muted,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isCurrent)
                                      IconButton(
                                        icon: const Icon(
                                          LucideIcons.logOut,
                                          color: AppColors.primary,
                                        ),
                                        onPressed: () => _logoutDevice(
                                          session['id'] as String,
                                        ),
                                        tooltip: 'Log out device',
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
