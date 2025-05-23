import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/shared_preferences_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends HookConsumerWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final scaleAnimation = useMemoized(
          () => Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.elasticOut,
        ),
      ),
      [animationController],
    );

    final fadeAnimation = useMemoized(
          () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
        ),
      ),
      [animationController],
    );

    useEffect(() {
      animationController.forward();

      // Navigate after animation and checking first time status
      Future.delayed(const Duration(milliseconds: 2500), () async {
        if (!context.mounted) return;

        final isFirstTime = await SharedPreferencesService.isFirstTime();
        final user = ref.read(currentUserProvider);

        if (isFirstTime) {
          await SharedPreferencesService.setNotFirstTime();
          if (context.mounted) {
            context.go('/login');
          }
        } else {
          if (context.mounted) {
            if (user != null) {
              context.go('/home');
            } else {
              context.go('/login');
            }
          }
        }
      });

      return null;
    }, []);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.note_alt_outlined,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: fadeAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.headline1.copyWith(
                          color: AppColors.onPrimary,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your thoughts, organized',
                        style: AppTextStyles.bodyText1.copyWith(
                          color: AppColors.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
            AnimatedBuilder(
              animation: fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: fadeAnimation.value,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.onPrimary.withOpacity(0.7),
                      ),
                    ),
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
