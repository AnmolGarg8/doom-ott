import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../data/repositories/auth_repository.dart';

class DeviceLimitScreen extends StatefulWidget {
  final List<dynamic> sessions;
  final VoidCallback? onRetry;

  const DeviceLimitScreen({
    super.key,
    required this.sessions,
    this.onRetry,
  });

  @override
  State<DeviceLimitScreen> createState() => _DeviceLimitScreenState();
}

class _DeviceLimitScreenState extends State<DeviceLimitScreen> {
  late List<dynamic> _activeSessions;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _activeSessions = List.from(widget.sessions);
  }

  Future<void> _logoutDevice(String sessionId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = context.read<AuthRepository>();
      await authRepo.deleteSession(sessionId);

      setState(() {
        _activeSessions.removeWhere((s) => s['id'] == sessionId);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device logged out successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop(); // Dismiss this screen
        widget.onRetry?.call(); // Retry login
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
          'Device Limit Reached',
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
              const Icon(
                LucideIcons.monitorOff,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppThemeConstants.space24),
              Text(
                'Too Many Active Devices',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemeConstants.space12),
              Text(
                'You have reached the maximum device limit allowed for your subscription. Log out of an active device below to continue logging in on this device.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemeConstants.space24),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
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
                              'No active sessions found.',
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
