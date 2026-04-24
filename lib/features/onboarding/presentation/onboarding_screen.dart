import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/services/onboarding_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/nexuly_logo.dart';
import '../../../shared/widgets/nexuly_pressable.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.health_and_safety_outlined,
      title: 'Nexuly te acompaña',
      body:
          'Recibe señales claras desde el primer momento para cuidar mejor en casa.',
      color: AppColors.violet600,
    ),
    _OnboardingPageData(
      icon: Icons.notifications_active_outlined,
      title: 'Alertas que llegan a tiempo',
      body:
          'Programa recordatorios y recibe avisos cuando una reserva necesita atención.',
      color: AppColors.info,
    ),
    _OnboardingPageData(
      icon: Icons.verified_user_outlined,
      title: 'Cuidado con confianza',
      body:
          'Encuentra profesionales verificados y mantén cada servicio bajo control.',
      color: AppColors.success,
    ),
  ];

  Future<void> _finish() async {
    await ref.read(onboardingServiceProvider).complete();
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              Row(
                children: [
                  const NexulyLogo(size: 34),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: const Text('Saltar')),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) => _OnboardingPage(
                    data: _pages[index],
                    active: index == _index,
                  ),
                ),
              ),
              SmoothPageIndicator(
                controller: _controller,
                count: _pages.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: AppColors.violet600,
                  dotColor: AppColors.gray200,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              NexulyPressable(
                borderRadius: BorderRadius.circular(AppRadii.md),
                onTap: _next,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradientButton,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          _index == _pages.length - 1 ? 'Empezar' : 'Continuar',
                          key: ValueKey(_index == _pages.length - 1),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data, required this.active});

  final _OnboardingPageData data;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PulseIllustration(data: data, active: active),
        const SizedBox(height: AppSpacing.xxxl),
        AnimatedSlide(
          offset: active ? Offset.zero : const Offset(0, 0.05),
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: active ? 1 : 0.45,
            duration: const Duration(milliseconds: 360),
            child: Column(
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  data.body,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PulseIllustration extends StatefulWidget {
  const _PulseIllustration({required this.data, required this.active});

  final _OnboardingPageData data;
  final bool active;

  @override
  State<_PulseIllustration> createState() => _PulseIllustrationState();
}

class _PulseIllustrationState extends State<_PulseIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = math.sin(_controller.value * math.pi * 2) * 0.04;
        return Transform.scale(
          scale: widget.active ? 1 + pulse : 0.92,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: widget.data.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160 + (_controller.value * 28),
                  height: 160 + (_controller.value * 28),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.data.color.withValues(alpha: 0.18),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.data.color, AppColors.purple500],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.color.withValues(alpha: 0.28),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Icon(widget.data.icon, color: Colors.white, size: 56),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
