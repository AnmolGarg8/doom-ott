import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/repositories/subscription_repository.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';

class PaymentScreen extends StatefulWidget {
  final String planId;
  final String planName;
  final double price;

  const PaymentScreen({
    super.key,
    required this.planId,
    required this.planName,
    required this.price,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _couponController = TextEditingController();

  String _selectedMethod = 'UPI';
  String? _appliedCoupon;
  double _discount = 0.0;
  String? _couponError;
  bool _isProcessing = false;
  bool _isSuccess = false;
  String? _processError;

  final Map<String, double> _validCoupons = {'DOOM50': 0.50, 'WELCOME10': 0.10};

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      if (_validCoupons.containsKey(code)) {
        _appliedCoupon = code;
        _discount = widget.price * _validCoupons[code]!;
        _couponError = null;
      } else {
        _appliedCoupon = null;
        _discount = 0.0;
        _couponError = 'Invalid coupon code';
      }
    });
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _discount = 0.0;
      _couponController.clear();
      _couponError = null;
    });
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _processError = null;
    });

    try {
      final repo = RepositoryProvider.of<SubscriptionRepository>(context);

      // 1. Checkout
      final checkoutData = await repo.checkout(
        widget.planId,
        couponCode: _appliedCoupon,
      );

      final orderId = checkoutData['order_id'] as String? ?? 'order_mock_123';

      // 2. Verify payment (PAYMENT_PROVIDER=mock always succeeds)
      final success = await repo.verifyPayment(
        orderId: orderId,
        paymentId: 'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
        signature: 'mock_signature',
      );

      if (success) {
        // Refresh User profile in AuthBloc
        if (mounted) {
          context.read<AuthBloc>().add(RefreshUserRequested());
        }

        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isSuccess = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _processError = 'Payment verification failed. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return _buildSuccessScreen();
    }

    final double totalAmount = widget.price - _discount;

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
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Processing payment securely...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_processError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Text(
                        _processError!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 1. Order Summary Card
                  _buildOrderSummaryCard(totalAmount),
                  const SizedBox(height: 24),

                  // 2. Coupon Input Field
                  _buildCouponSection(),
                  const SizedBox(height: 24),

                  // 3. Payment Methods
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodsList(),
                  const SizedBox(height: 32),

                  // 4. Pay Button
                  PrimaryButton(
                    label: 'Pay ₹${totalAmount.round()}',
                    onPressed: _processPayment,
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.shieldCheck,
                        color: Colors.white54,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Secured by Razorpay. 256-bit encryption.',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderSummaryCard(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.planName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '₹${widget.price.round()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (_discount > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Coupon Discount ($_appliedCoupon)',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '- ₹${_discount.round()}',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                '₹${total.round()}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Have a Coupon Code?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter code (e.g. DOOM50)',
                  errorText: _couponError,
                  suffixIcon: _appliedCoupon != null
                      ? IconButton(
                          icon: const Icon(
                            LucideIcons.checkCircle,
                            color: Color(0xFF2E7D32),
                          ),
                          onPressed: _removeCoupon,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _appliedCoupon != null ? null : _applyCoupon,
                child: const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        if (_appliedCoupon != null)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Coupon discount applied successfully!',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentMethodsList() {
    final methods = [
      {
        'name': 'UPI',
        'subtitle': 'Google Pay, PhonePe, Paytm',
        'icon': LucideIcons.smartphone,
      },
      {
        'name': 'Credit/Debit Card',
        'subtitle': 'Visa, Mastercard, RuPay',
        'icon': LucideIcons.creditCard,
      },
      {
        'name': 'Net Banking',
        'subtitle': 'All major Indian banks',
        'icon': LucideIcons.landmark,
      },
      {
        'name': 'Wallets',
        'subtitle': 'Amazon Pay, MobiKwik',
        'icon': LucideIcons.wallet,
      },
    ];

    return Column(
      children: methods.map((m) {
        final isSelected = m['name'] == _selectedMethod;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMethod = m['name'] as String;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFF1F1F1F),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  m['icon'] as IconData,
                  color: isSelected ? AppColors.primary : Colors.white70,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m['subtitle'] as String,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                  color: isSelected ? AppColors.primary : Colors.white24,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                LucideIcons.checkCircle2,
                color: AppColors.primary,
                size: 96,
              ),
              const SizedBox(height: 32),

              Text(
                'Subscription Activated!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                'Congratulations! You are now subscribed to ${widget.planName}. Enjoy unlimited buffer-free streaming of movies, TV shows, and exclusive Originals.',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              PrimaryButton(
                label: 'Start Watching',
                onPressed: () {
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
