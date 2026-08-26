import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';

class CongratulationsScreen extends StatefulWidget {
  final String species;
  final String? damMareId;
  final String? stallionName;

  const CongratulationsScreen({
    super.key,
    this.species = 'Equine',
    this.damMareId,
    this.stallionName,
  });

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _confettiController;
  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Grand entrance crest pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.10).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.10, end: 0.97).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.97, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_pulseController);

    // Confetti explosion animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _generateConfetti();
    _pulseController.forward();
    _confettiController.forward();
  }

  void _generateConfetti() {
    _particles.clear();
    final random = math.Random();
    const colors = [
      AppColors.primaryGold,
      Color(0xFFF59E0B), // Amber
      Color(0xFF10B981), // Emerald
      Color(0xFFEC4899), // Pink
      Color(0xFF3B82F6), // Blue
      Color(0xFFE5E7EB), // Silver/White
    ];

    for (int i = 0; i < 45; i++) {
      _particles.add(
        _ConfettiParticle(
          x: random.nextDouble(),
          y: -0.1 - random.nextDouble() * 0.4,
          vx: (random.nextDouble() - 0.5) * 0.4,
          vy: 0.3 + random.nextDouble() * 0.6,
          size: 6 + random.nextDouble() * 8,
          rotation: random.nextDouble() * 2 * math.pi,
          rotationSpeed: (random.nextDouble() - 0.5) * 6,
          color: colors[random.nextInt(colors.length)],
          shape: random.nextInt(3), // 0: rectangle, 1: circle, 2: star
        ),
      );
    }
  }

  void _triggerCelebrationAgain() {
    _generateConfetti();
    _pulseController.reset();
    _pulseController.forward();
    _confettiController.reset();
    _confettiController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCanine = widget.species.toLowerCase().trim() == 'canine';
    final speciesLabel = isCanine ? 'Puppy Litter' : 'Foal Arrival';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.35),
                  radius: 0.85,
                  colors: [
                    Color(0xFF2C220E),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),

          // Main Celebratory Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding, vertical: 20),
              child: ResponsiveBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // Top Milestone Tag
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryGold, width: 1),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: AppColors.primaryGold, size: 13),
                              const SizedBox(width: 5),
                              Text(
                                'BREEDING MILESTONE ACHIEVED',
                                style: AppTypography.finePrint.copyWith(
                                  color: AppColors.primaryGold,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.star, color: AppColors.primaryGold, size: 13),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Animated Glowing Grand Crest
                    Center(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFDF7A),
                                AppColors.primaryGold,
                                Color(0xFF996B1E),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGold.withValues(alpha: 0.5),
                                blurRadius: 36,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 112,
                              height: 112,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.background,
                              ),
                              child: Center(
                                child: Icon(
                                  isCanine ? Icons.pets : Icons.auto_awesome,
                                  size: 58,
                                  color: AppColors.primaryGold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Big Vibrant Headline
                    Text(
                      'CONGRATULATIONS!',
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.primaryGold,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'A NEW LIFE HAS ARRIVED SAFELY',
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      isCanine
                          ? 'Congratulations on your new litter! The whelping journey is complete and a joyous new chapter begins.'
                          : 'Congratulations on your new arrival! The gestation period is complete, welcoming the future of your breeding program.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // First 24-Hours Vital Protocol Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Color(0xFF10B981), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isCanine
                                      ? 'FIRST 24-HOUR CRITICAL WHELPING CHECKLIST'
                                      : 'THE 1-2-3 FOALING RULE (FIRST HOURS)',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.inputField, height: 18),
                          if (!isCanine) ...[
                            _buildProtocolRow(
                              '⏱️ Hour 1',
                              'Foal should be standing on all four feet independently.',
                            ),
                            const SizedBox(height: 8),
                            _buildProtocolRow(
                              '🍼 Hour 2',
                              'Foal should be actively nursing colostrum (essential immunity).',
                            ),
                            const SizedBox(height: 8),
                            _buildProtocolRow(
                              '🩺 Hour 3',
                              'Mare should pass complete placenta intact & meconium passed.',
                            ),
                          ] else ...[
                            _buildProtocolRow(
                              '🌡️ Warmth',
                              'Maintain whelping box temperature at 28-30°C with clean bedding.',
                            ),
                            const SizedBox(height: 8),
                            _buildProtocolRow(
                              '🍼 Colostrum',
                              'Ensure each pup nurses immediately to receive maternal antibodies.',
                            ),
                            const SizedBox(height: 8),
                            _buildProtocolRow(
                              '⚖️ Birth Weight',
                              'Weigh and identify each pup to establish baseline daily growth.',
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Primary Action: Register New Foal/Puppy Record
                    GradientCtaButton(
                      text: isCanine
                          ? '📸 REGISTER NEW PUPPY & BIRTH RECORD'
                          : '📸 REGISTER NEW FOAL & BIRTH RECORD',
                      onPressed: () {
                        if (isCanine) {
                          Navigator.pushReplacementNamed(context, '/puppy-details');
                        } else {
                          Navigator.pushReplacementNamed(
                            context,
                            '/foal-details',
                            arguments: {
                              'damMareId': widget.damMareId,
                              'stallion': widget.stallionName,
                            },
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // Interactive Celebrate Again Trigger
                    OutlinedButton.icon(
                      onPressed: _triggerCelebrationAgain,
                      icon: const Icon(Icons.celebration, color: AppColors.primaryGold, size: 18),
                      label: const Text(
                        'CELEBRATE AGAIN 🎉',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGold),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Return to Dashboard
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      },
                      child: Text(
                        'RETURN TO DASHBOARD',
                        style: AppTypography.buttonLabel.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Animated Falling Confetti Particles Canvas
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      progress: _confettiController.value,
                      particles: _particles,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolRow(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double rotation;
  double rotationSpeed;
  Color color;
  int shape;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    for (final p in particles) {
      final curX = (p.x + p.vx * progress) * size.width;
      final curY = (p.y + p.vy * progress * 1.5) * size.height;
      final curRotation = p.rotation + p.rotationSpeed * progress;
      final alpha = (1.0 - (progress * 0.9)).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(curX, curY);
      canvas.rotate(curRotation);

      if (p.shape == 0) {
        // Ribbon / Rectangle
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size * 1.6, height: p.size * 0.7),
          paint,
        );
      } else if (p.shape == 1) {
        // Circle speck
        canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
      } else {
        // Diamond / Star
        final path = Path()
          ..moveTo(0, -p.size * 0.8)
          ..lineTo(p.size * 0.6, 0)
          ..lineTo(0, p.size * 0.8)
          ..lineTo(-p.size * 0.6, 0)
          ..close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

