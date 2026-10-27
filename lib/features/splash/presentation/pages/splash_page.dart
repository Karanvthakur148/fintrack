
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fintrack/core/theme/app_colors.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';
import '../../domain/usecases/wait_for_splash.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.onFinished,
  });

  final VoidCallback onFinished;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotationAnimation;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _rotationAnimation = Tween<double>(
      begin: -0.12,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  void _finish() {
    if (_hasNavigated || !mounted) return;

    _hasNavigated = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finColors =
        theme.extension<FinColors>() ?? FinColors.light;

    return BlocProvider(
      create: (_) => SplashBloc(
        waitForSplash: const WaitForSplash(),
      )..add(const SplashStarted()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state.status == SplashStatus.completed) {
           // _finish();
            widget.onFinished();

          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              _BackgroundDecoration(
                color: finColors.heroStart,
              ),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // Animated logo
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: RotationTransition(
                              turns: _rotationAnimation,
                              child: _FinTrackLogo(
                                finColors: finColors,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Brand name and tagline
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.5,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Fin'),
                                    TextSpan(
                                      text: 'Track',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Track Today, Build Tomorrow',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  letterSpacing: 0.5,
                                  color: theme.colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Finance illustration
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _FinanceIllustration(
                            finColors: finColors,
                          ),
                        ),

                        const Spacer(flex: 2),

                        // BLoC-driven loading/error UI
                        BlocBuilder<SplashBloc, SplashState>(
                          builder: (context, state) {
                            if (state.status == SplashStatus.failure) {
                              return Column(
                                children: [
                                  Text(
                                    'Unable to start the app.',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<SplashBloc>()
                                          .add(const SplashStarted());
                                    },
                                    child: const Text('Try again'),
                                  ),
                                ],
                              );
                            }

                            return _LoadingIndicator(
                              color: AppColors.primary,
                            );
                          },
                        ),

                        const SizedBox(height: 28),
                      ],
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

class _FinTrackLogo extends StatelessWidget {
  const _FinTrackLogo({
    required this.finColors,
  });

  final FinColors finColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            finColors.heroStart,
            finColors.heroEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: finColors.heroEnd.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(
        Icons.trending_up_rounded,
        color: Colors.white,
        size: 66,
      ),
    );
  }
}

class _FinanceIllustration extends StatelessWidget {
  const _FinanceIllustration({
    required this.finColors,
  });

  final FinColors finColors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 270,
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 35,
            top: 27,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                width: 137,
                height: 164,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: finColors.heroEnd,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: finColors.heroEnd
                          .withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 55,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _ChartBar(height: 20),
                        SizedBox(width: 6),
                        _ChartBar(height: 34),
                        SizedBox(width: 6),
                        _ChartBar(height: 48),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 40,
            top: 15,
            child: Icon(
              Icons.eco_rounded,
              size: 62,
              color: finColors.income,
            ),
          ),

          const Positioned(
            right: 24,
            bottom: 24,
            child: _Coin(),
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFC247),
        border: Border.all(
          color: const Color(0xFFE5A62C),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC247)
                .withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.currency_rupee_rounded,
        size: 42,
        color: Color(0xFF8B5B00),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
          minHeight: 6,
          backgroundColor: color.withValues(alpha: 0.18),
          color: color,
        ),
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -100,
            top: -120,
            child: _SoftCircle(
              size: 280,
              color: color,
            ),
          ),
          Positioned(
            right: -110,
            bottom: -120,
            child: _SoftCircle(
              size: 300,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }
}
