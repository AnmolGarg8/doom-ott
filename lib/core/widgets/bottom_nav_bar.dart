import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'icon': LucideIcons.home, 'label': 'Home'},
      {'icon': LucideIcons.tv, 'label': 'Live TV'},
      {'icon': LucideIcons.zap, 'label': 'Minis'},
      {'icon': LucideIcons.bookmark, 'label': 'My List'},
      {'icon': LucideIcons.user, 'label': 'Profile'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double slotWidth = totalWidth / items.length;

        // Active indicator dimensions inside the slot
        const double verticalMargin = 8.0;
        const double horizontalMargin = 6.0;
        final double indicatorWidth = slotWidth - (horizontalMargin * 2);

        return ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.18),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 1. Sliding Glowing Active Indicator Pill
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutBack,
                    left: (currentIndex * slotWidth) + horizontalMargin,
                    top: verticalMargin,
                    width: indicatorWidth,
                    height: 64 - (verticalMargin * 2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Navigation Items Row
                  Row(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isSelected = index == currentIndex;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(index),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon
                              Icon(
                                item['icon'] as IconData,
                                color: isSelected
                                    ? const Color(0xFF0A0A0A)
                                    : const Color(0xFF8A8A8A),
                                size: 20,
                              ),
                              // Active Label (Fades in dynamically)
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: isSelected ? 1.0 : 0.0,
                                child: isSelected
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          top: 2.0,
                                        ),
                                        child: Text(
                                          item['label'] as String,
                                          style: const TextStyle(
                                            color: Color(0xFF0A0A0A),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
