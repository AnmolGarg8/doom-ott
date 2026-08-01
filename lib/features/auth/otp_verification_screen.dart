import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/primary_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  late Timer _timer;
  int _secondsRemaining = 60;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    String otp = '';
    for (var ctrl in _controllers) {
      otp += ctrl.text;
    }

    if (otp.length < 6) {
      setState(() {
        _errorMessage = 'Please enter complete 6-digit OTP code.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    context.read<AuthBloc>().add(VerifyOtpRequested(otp));
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
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ProfileSetupRequiredState) {
            context.go('/auth/profile-setup');
          } else if (state is AuthError) {
            setState(() {
              _errorMessage = state.message;
            });
            // Clear inputs on wrong OTP
            for (var ctrl in _controllers) {
              ctrl.clear();
            }
            _focusNodes[0].requestFocus();
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Verify OTP',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the 6-digit verification code sent to your phone number.',
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tip: Enter 111111 to test the intentional error flow state.',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 40),

                // 6 digits fields row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 44,
                      child: TextFormField(
                        focusNode: _focusNodes[index],
                        controller: _controllers[index],
                        enabled: !isLoading,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLength: 1,
                        decoration: const InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          if (index == 5 && value.length == 1) {
                            _focusNodes[index].unfocus();
                            _verifyOtp();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Inline Error Display (#FF5252 Red)
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFFF5252), // Brand-safe verification Red
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Countdown timer
                Center(
                  child: _secondsRemaining > 0
                      ? Text(
                          'Resend OTP in ${_secondsRemaining}s',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                          ),
                        )
                      : TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  _startTimer();
                                  // Mock resending OTP
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'OTP code resent successfully.',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                          child: const Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const Spacer(),

                PrimaryButton(
                  label: 'Verify & Continue',
                  isLoading: isLoading,
                  onPressed: _verifyOtp,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
