import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';

class SubscriptionPlan {
  final String name;
  final double price;
  final String duration;
  final String? savingsBadge;
  final bool isPopular;
  final List<String> features;

  const SubscriptionPlan({
    required this.name,
    required this.price,
    required this.duration,
    this.savingsBadge,
    this.isPopular = false,
    required this.features,
  });
}

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // Mock current active plan
  final String _currentPlanName = 'Monthly Basic';

  final List<SubscriptionPlan> _plans = const [
    SubscriptionPlan(
      name: 'Monthly Basic',
      price: 199.0,
      duration: 'month',
      features: [
        '1 Screen sharing limit',
        'Full HD (1080p) Streaming',
        'Includes standard sponsorships',
        'Mobile & TV Support',
      ],
    ),
    SubscriptionPlan(
      name: 'Quarterly Premium',
      price: 499.0,
      duration: '3 months',
      savingsBadge: 'Save 16%',
      isPopular: true,
      features: [
        '2 Screens sharing limit',
        'Ultra HD (4K) Streaming',
        'Completely Ad-Free',
        'Offline Downloads support',
      ],
    ),
    SubscriptionPlan(
      name: 'Annual Ultimate',
      price: 1499.0,
      duration: 'year',
      savingsBadge: 'Save 37%',
      features: [
        '4 Screens sharing limit',
        '4K HDR + Dolby Vision audio',
        'Completely Ad-Free',
        'Unlimited Offline Downloads',
        'Priority early access to Originals',
      ],
    ),
  ];

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
          'Choose Your Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Flexible plans for every DOOM fan. Upgrade or cancel anytime.',
              style: TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Plan List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                final plan = _plans[index];
                final isCurrent = plan.name == _currentPlanName;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primary
                          : plan.isPopular
                          ? AppColors.primary.withOpacity(0.4)
                          : const Color(0xFF1F1F1F),
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Badge overlay row (Current Plan or Savings tag)
                      if (isCurrent ||
                          plan.savingsBadge != null ||
                          plan.isPopular)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'CURRENT PLAN',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                )
                              else if (plan.isPopular)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'MOST POPULAR',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(),
                              if (plan.savingsBadge != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    plan.savingsBadge!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Plan header (Title + Price)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  plan.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  textBaseline: TextBaseline.alphabetic,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  children: [
                                    Text(
                                      '₹${plan.price.round()}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      '/${plan.duration}',
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 16),

                            // Feature items checklist
                            ...plan.features.map(
                              (f) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.checkCircle2,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        f,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Action button upgrade / subscribe
                            PrimaryButton(
                              label: isCurrent
                                  ? 'Active'
                                  : isCurrent == false && plan.price > 199
                                  ? 'Upgrade Plan'
                                  : 'Subscribe Now',
                              onPressed: isCurrent
                                  ? null
                                  : () {
                                      context.push(
                                        '/payment?planName=${plan.name}&price=${plan.price}',
                                      );
                                    },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
