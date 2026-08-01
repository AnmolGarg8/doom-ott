import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';

class PaymentScreen extends StatefulWidget {
  final String planName;
  final double price;

  const PaymentScreen({super.key, required this.planName, required this.price});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _couponController = TextEditingController();

  // Selections & States
  String _selectedMethod = 'UPI';
  String? _appliedCoupon;
  double _discount = 0.0;
  String? _couponError;
  bool _isProcessing = false;
  bool _isSuccess = false;

  final Map<String, double> _validCoupons = {
    'DOOM50': 0.50, // 50% Discount
    'WELCOME10': 0.10, // 10% Discount
  };

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
    });

    // Simulate Payment Processing (Razorpay SDK delay)
    // TODO: Integrate Razorpay SDK payment sheet flow here when real backend is connected.
    // E.g., Razorpay.open(options);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
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

    return RadioGroup<String>(
      groupValue: _selectedMethod,
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedMethod = val;
          });
        }
      },
      child: Column(
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
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF1F1F1F),
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
                  Radio<String>(
                    value: m['name'] as String,
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
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
              // Animated Scale Checkmark
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
