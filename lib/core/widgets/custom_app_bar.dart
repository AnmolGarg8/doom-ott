import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ScrollController? scrollController;
  final Widget? title;
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;
  final double? backgroundOpacity;

  const CustomAppBar({
    super.key,
    this.scrollController,
    this.title,
    this.onSearchTap,
    this.onProfileTap,
    this.backgroundOpacity,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController != null) {
      final offset = widget.scrollController!.offset;
      final newOpacity = (offset / 150.0).clamp(0.0, 1.0);
      if (newOpacity != _opacity) {
        setState(() {
          _opacity = newOpacity;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (widget.backgroundOpacity ?? _opacity).clamp(0.0, 1.0);

    return Container(
      color: Colors.black.withValues(alpha: opacity),
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.title ??
                const Text(
                  'DOOM OTT',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.search, color: Colors.white),
                  onPressed:
                      widget.onSearchTap ?? () => context.push('/search'),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onProfileTap ?? () => context.push('/profile'),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                    ),
                    child: const Icon(
                      LucideIcons.user,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
