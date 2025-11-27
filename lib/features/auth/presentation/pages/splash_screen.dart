import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tribe/core/theme/app_theme.dart';
import 'package:tribe/features/auth/presentation/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Trigger auth check immediately
    context.read<AuthBloc>().add(AuthCheckRequested());

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Fade out controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Logo scale animation (bounce effect)
    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_logoController);

    // Logo rotation animation (subtle rotation)
    _logoRotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));

    // Text fade animation
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Text slide animation
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // Fade out animation
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    await _logoController.forward();
    
    // Start text animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    await _textController.forward();
    
    // Wait for auth check to complete (minimum 1.5 seconds for animations)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Wait for auth state to be determined (not initial or loading)
    await _waitForAuthCheck();
    
    // Fade out
    await _fadeController.forward();
    
    // Navigate based on auth state
    if (mounted) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.go('/home');
      } else {
        context.go('/welcome');
      }
    }
  }

  Future<void> _waitForAuthCheck() async {
    // Wait until auth state is determined (not initial or loading)
    final authBloc = context.read<AuthBloc>();
    int attempts = 0;
    const maxAttempts = 50; // 5 seconds max wait (50 * 100ms)
    
    while (mounted && attempts < maxAttempts) {
      final state = authBloc.state;
      if (state is! AuthInitial && state is! AuthLoading) {
        // Auth check completed
        break;
      }
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Listen to auth state changes to navigate when ready
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Only navigate if we're past the initial animation phase
        // This prevents premature navigation during splash animation
        if (_fadeController.isCompleted || _fadeController.isAnimating) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthUnauthenticated || state is AuthFailure) {
            context.go('/welcome');
          }
        }
      },
      child: Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppTheme.backgroundDark,
                      AppTheme.backgroundDark.withOpacity(0.95),
                    ]
                  : [
                      AppTheme.backgroundLight,
                      AppTheme.primaryLight.withOpacity(0.3),
                    ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotationAnimation.value,
                          child: Container(
                            width: 450,
                            height: 450,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                  blurRadius: 75,
                                  spreadRadius: 25,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/tribe_transparent_logo_.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Animated Text
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Tribe',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppTheme.textDark
                                      : AppTheme.textLight,
                                  letterSpacing: 2,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Together we achieve more',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isDark
                                      ? AppTheme.subtleDark
                                      : AppTheme.subtleLight,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w300,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

