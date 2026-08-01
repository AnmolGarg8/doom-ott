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

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+91';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      final fullNumber =
          '$_selectedCountryCode ${_phoneController.text.trim()}';
      context.read<AuthBloc>().add(SendOtpRequested(fullNumber));
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
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSentState) {
            context.push('/auth/otp');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter your Phone Number',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We will send a 6-digit OTP code to verify your account.',
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  // Country Code + Phone field row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Country code picker container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppThemeConstants.radiusButton,
                          ),
                          border: Border.all(color: const Color(0xFF1F1F1F)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            dropdownColor: AppColors.surface,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedCountryCode = value;
                                      });
                                    }
                                  },
                            items: const [
                              DropdownMenuItem(
                                value: '+91',
                                child: Text(
                                  '+91',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DropdownMenuItem(
                                value: '+1',
                                child: Text(
                                  '+1',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DropdownMenuItem(
                                value: '+44',
                                child: Text(
                                  '+44',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DropdownMenuItem(
                                value: '+971',
                                child: Text(
                                  '+971',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Phone number field
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '99999 99999',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            if (value.trim().length < 8) {
                              return 'Enter valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  PrimaryButton(
                    label: 'Send OTP',
                    isLoading: isLoading,
                    onPressed: _sendOtp,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
