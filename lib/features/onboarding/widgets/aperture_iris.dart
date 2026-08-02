import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class ApertureIris extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const ApertureIris({super.key, required this.child, required this.isActive});

  @override
  State<ApertureIris> createState() => _ApertureIrisState();
}

class _ApertureIrisState extends State<ApertureIris>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      reverseDuration: const Duration(milliseconds: 400),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ApertureIris oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        // Calculate dynamic aperture opening radius
        return Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. The scene (child) clipped to the central opening
                ClipPath(
                  clipper: _ApertureClipper(progress: progress),
                  child: widget.child,
                ),
                // 2. The aperture blades painted on top
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ApertureBladesPainter(progress: progress),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ApertureClipper extends CustomClipper<Path> {
  final double progress;

  _ApertureClipper({required this.progress});

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Opening grows from 0 to 110px radius (almost full width of the 260px container)
    final radius = progress * 110.0;

    final path = Path();
    if (radius > 0) {
      path.addOval(Rect.fromCircle(center: center, radius: radius));
    }
    return path;
  }

  @override
  bool shouldReclip(covariant _ApertureClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

class _ApertureBladesPainter extends CustomPainter {
  final double progress;

  _ApertureBladesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;
    final outerRadius = math.sqrt(width * width + height * height) / 2;
    // Current opening radius
    final innerRadius = progress * 110.0;

    const numBlades = 8;
    // Rotation of blades shifts as they open/close
    final rotationOffset = (1.0 - progress) * (math.pi / 4);

    final paintBlade = Paint();
    final paintRim = Paint()
      ..color = AppColors.emberAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < numBlades; i++) {
      final double angleStart = (2 * math.pi / numBlades) * i + rotationOffset;
      final double angleEnd =
          (2 * math.pi / numBlades) * (i + 1) + rotationOffset;

      // 1. Blade path geometry representing the mechanical overlapping sheet
      final path = Path();

      // inner points
      final pInnerStart = Offset(
        center.dx + innerRadius * math.cos(angleStart),
        center.dy + innerRadius * math.sin(angleStart),
      );
      final pInnerEnd = Offset(
        center.dx + innerRadius * math.cos(angleEnd),
        center.dy + innerRadius * math.sin(angleEnd),
      );

      // outer points (well outside the viewport bounds)
      final pOuterStart = Offset(
        center.dx + outerRadius * math.cos(angleStart - 0.2),
        center.dy + outerRadius * math.sin(angleStart - 0.2),
      );
      final pOuterEnd = Offset(
        center.dx + outerRadius * math.cos(angleEnd + 0.3),
        center.dy + outerRadius * math.sin(angleEnd + 0.3),
      );

      path.moveTo(pInnerStart.dx, pInnerStart.dy);
      path.lineTo(pInnerEnd.dx, pInnerEnd.dy);
      path.lineTo(pOuterEnd.dx, pOuterEnd.dy);
      path.lineTo(pOuterStart.dx, pOuterStart.dy);
      path.close();

      // Blade metallic gradient from inner rim to outer edge
      paintBlade.shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          const Color(0xFF3A3A3A),
          const Color(0xFF1E1E1E),
          AppColors.inkBlack,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));

      // Draw the blade background
      canvas.drawPath(path, paintBlade);

      // Amber rim light edge on the trailing inner border of each blade
      if (innerRadius > 1) {
        canvas.drawLine(pInnerStart, pInnerEnd, paintRim);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ApertureBladesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
