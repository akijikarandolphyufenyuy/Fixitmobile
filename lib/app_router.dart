import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme_provider.dart';

// PAGES
import 'features/onboarding/homepage.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/signup_page.dart';
import 'features/auth/forgot_password_page.dart';
import 'features/dashboard/home_page.dart';
import 'features/dashboard/view_jobs_page.dart';
import 'features/dashboard/apply_jobs_page.dart';
import 'features/dashboard/my_jobs_page.dart';
import 'features/dashboard/applications_page.dart';
import 'features/dashboard/post_job_page.dart';
import 'features/dashboard/my_cv_page.dart';
import 'features/dashboard/fixit_assistance_page.dart';
import 'features/dashboard/settings_page.dart';
import 'features/dashboard/notification_page.dart';
import 'features/subscription/subscription_page.dart';
import 'features/dashboard/about_page.dart';
import 'features/dashboard/job_applicants_page.dart';
import 'features/transactions/transactions_page.dart';
import 'features/payment/payment_screen.dart';

// REPOSITORIES
import 'data/repositories/auth_repository.dart';

// Shared transition builder — fade + subtle upward slide
Page<T> _page<T>(LocalKey key, Widget child, {bool isModal = false}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: isModal ? const Offset(0, 0.06) : const Offset(0.04, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fadeOut = Tween<double>(begin: 1.0, end: 0.92)
          .animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn));
      return FadeTransition(
        opacity: fadeOut,
        child: FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        ),
      );
    },
  );
}

class AppRouter {
  static GoRouter build(AuthRepository authRepository) {
    final auth = AuthRepository.instance;

    return GoRouter(
      initialLocation: '/',
      refreshListenable: auth,
      redirect: (context, state) {
        final location = state.uri.toString();
        if (!auth.isReady) return null;

        final loggedIn = auth.isLoggedIn();
        final isPublicRoute =
            location == '/' ||
            location.startsWith('/login') ||
            location.startsWith('/signup') ||
            location.startsWith('/forgot-password') ||
            location.startsWith('/onboarding');

        if (loggedIn && isPublicRoute && !location.startsWith('/onboarding')) {
          return '/dashboard/home';
        }
        if (!loggedIn && !isPublicRoute) {
          return '/login';
        }
        return null;
      },
      routes: [
        // Onboarding & Auth
        GoRoute(path: '/',                  pageBuilder: (_, s) => _page(s.pageKey, const OnboardingHomePage())),
        GoRoute(path: '/onboarding/home',   pageBuilder: (_, s) => _page(s.pageKey, const OnboardingHomePage())),
        GoRoute(path: '/onboarding/1',      pageBuilder: (_, s) => _page(s.pageKey, const OnboardingPage())),
        GoRoute(path: '/onboarding/2',      pageBuilder: (_, s) => _page(s.pageKey, const OnboardingPage())),
        GoRoute(path: '/onboarding/3',      pageBuilder: (_, s) => _page(s.pageKey, const OnboardingPage())),
        GoRoute(path: '/login',             pageBuilder: (_, s) => _page(s.pageKey, const LoginPage())),
        GoRoute(path: '/signup',            pageBuilder: (_, s) => _page(s.pageKey, const SignupPage())),
        GoRoute(path: '/forgot-password',   pageBuilder: (_, s) => _page(s.pageKey, const ForgotPasswordPage())),

        // Dashboard
        GoRoute(path: '/dashboard/home',         pageBuilder: (_, s) => _page(s.pageKey, const HomePage())),
        GoRoute(path: '/dashboard/jobs',         pageBuilder: (_, s) => _page(s.pageKey, const ViewJobsPage())),
        GoRoute(path: '/dashboard/post-job',     pageBuilder: (_, s) => _page(s.pageKey, const PostJobPage())),
        GoRoute(path: '/dashboard/applications', pageBuilder: (_, s) => _page(s.pageKey, const ApplicationsPage())),
        GoRoute(path: '/dashboard/settings',     pageBuilder: (context, s) {
          final themeProvider = ThemeProvider.of(context);
          return _page(s.pageKey, SettingsPage(onToggleTheme: themeProvider.toggleTheme));
        }),
        GoRoute(path: '/dashboard/notifications', pageBuilder: (_, s) => _page(s.pageKey, const NotificationPage())),
        GoRoute(path: '/dashboard/my-jobs',       pageBuilder: (_, s) => _page(s.pageKey, const MyJobsPage())),
        GoRoute(path: '/dashboard/apply-jobs',    pageBuilder: (_, s) => _page(s.pageKey, const ApplyJobsPage())),
        GoRoute(path: '/dashboard/my-cv',         pageBuilder: (_, s) => _page(s.pageKey, const MyCvPage())),
        GoRoute(path: '/dashboard/fixit-assistance', pageBuilder: (_, s) => _page(s.pageKey, const FixitAssistancePage())),
        GoRoute(path: '/dashboard/subscription',  pageBuilder: (_, s) => _page(s.pageKey, const SubscriptionPage())),
        GoRoute(path: '/dashboard/view-jobs',     pageBuilder: (_, s) => _page(s.pageKey, const ViewJobsPage())),
        GoRoute(path: '/subscription',            pageBuilder: (_, s) => _page(s.pageKey, const SubscriptionPage())),
        GoRoute(path: '/dashboard/about',         pageBuilder: (_, s) => _page(s.pageKey, const AboutPage())),
        GoRoute(path: '/dashboard/transactions',  pageBuilder: (_, s) => _page(s.pageKey, const TransactionsPage())),
        GoRoute(
          path: '/payment',
          pageBuilder: (_, s) {
            final extra = s.extra as Map<String, dynamic>;
            return _page(s.pageKey,
              PaymentScreen(
                purpose:   extra['purpose']   as String,
                amount:    extra['amount']    as int,
                jobTitle:  extra['jobTitle']  as String?,
                onSuccess: extra['onSuccess'] as void Function(),
              ),
              isModal: true,
            );
          },
        ),
        GoRoute(
          path: '/dashboard/job-applicants/:jobId',
          pageBuilder: (_, s) => _page(s.pageKey,
            JobApplicantsPage(
              jobId:    s.pathParameters['jobId'] ?? '',
              jobTitle: s.extra as String? ?? 'Job',
            ),
          ),
        ),
      ],
    );
  }
}
