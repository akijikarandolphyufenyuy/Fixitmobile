//import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme_provider.dart';

// PAGES
import 'features/onboarding/homepage.dart';
import 'features/onboarding/onboarding1_page.dart';
import 'features/onboarding/onboarding2_page.dart';
import 'features/onboarding/onboarding3_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/signup_page.dart';
import 'features/auth/forgot_password_page.dart';
import 'features/subscription/subscription_page.dart';
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
import 'features/dashboard/subsciption_page.dart' hide SubscriptionPage;

// REPOSITORIES
import 'data/repositories/auth_repository.dart';

class AppRouter {
  static GoRouter build(AuthRepository authRepository) {
    final auth = AuthRepository.instance;

    return GoRouter(
      initialLocation: '/',
      refreshListenable: auth,
      redirect: (context, state) => _handleRedirect(auth, state),
      routes: [
        // -------------------------
        // Onboarding & Auth Routes
        // -------------------------
        GoRoute(
          path: '/',
          builder: (context, state) => const OnboardingHomePage(),
        ),
        GoRoute(
          path: '/onboarding/home',
          builder: (context, state) => const OnboardingHomePage(),
        ),
        GoRoute(
          path: '/onboarding/1',
          builder: (context, state) => const Onboarding1Page(),
        ),
        GoRoute(
          path: '/onboarding/2',
          builder: (context, state) => const Onboarding2Page(),
        ),
        GoRoute(
          path: '/onboarding/3',
          builder: (context, state) => const Onboarding3Page(),
        ),
        // GoRoute(
        //   path: '/subscription',
        //   builder: (context, state) => const SubscriptionPage(),
        // ),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),

        // -------------------------
        // DASHBOARD ROUTES - Matching the first example structure
        // -------------------------
        GoRoute(
          path: '/dashboard/home',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: '/dashboard/notifications',
          builder: (context, state) => NotificationPage(),
        ),
        GoRoute(
          path: '/dashboard/jobs',
          builder: (context, state) => ViewJobsPage(),
        ),
        GoRoute(
          path: '/dashboard/post-job',
          builder: (context, state) => PostJobPage(),
        ),
        GoRoute(
          path: '/dashboard/settings',
          builder: (context, state) {
            final themeProvider = ThemeProvider.of(context);
            return SettingsPage(onToggleTheme: themeProvider.toggleTheme);
          },
        ),
        GoRoute(
          path: '/dashboard/my-jobs',
          builder: (context, state) => MyJobsPage(),
        ),
        GoRoute(
          path: '/dashboard/apply-jobs',
          builder: (context, state) => ApplyJobsPage(),
        ),
        GoRoute(
          path: '/dashboard/applications',
          builder: (context, state) => ApplicationsPage(),
        ),
        GoRoute(
          path: '/dashboard/my-cv',
          builder: (context, state) => MyCvPage(),
        ),
        GoRoute(
          path: '/dashboard/fixit-assistance',
          builder: (context, state) => FixitAssistancePage(),
        ),
        GoRoute(
          path: '/dashboard/subscription',
          builder: (context, state) => SubscriptionPage(),
        ),
        GoRoute(
          path: '/dashboard/view-jobs',
          builder: (context, state) => ViewJobsPage(),
        ),
      ],
    );
  }

  // -------------------------
  // Redirect Handler
  // -------------------------
  static String? _handleRedirect(AuthRepository auth, GoRouterState state) {
    final location = state.uri.toString();

    if (!auth.isReady) return null;

    final loggedIn = auth.isLoggedIn();
    final isPublicRoute =
        [
          '/',
          '/login',
          '/signup',
          '/forgot-password',
          '/subscription',
        ].any((path) => location.startsWith(path)) ||
        location.startsWith('/onboarding');

    if (loggedIn) {
      final needsSub =
          auth.currentUser != null && (auth.currentUser!.email ?? '').isEmpty;
      final isFirstRun = false;
      print(
        'Logged In: $loggedIn, Needs Subscription: $needsSub, Is First Run: $isFirstRun',
      );

      // Allow navigation to settings page even if subscription is needed
      if (location == '/dashboard/settings') {
        print('Allowing access to settings page.');
        return null; // Explicitly allow settings page

        if (isFirstRun && !location.startsWith('/onboarding')) {
          return '/onboarding/home';
        }
        if (needsSub && !location.startsWith('/subscription')) {
          return '/subscription';
        }
        if (isPublicRoute && !location.startsWith('/onboarding')) {
          return '/dashboard/home';
        }
      }
    } else {
      return isPublicRoute ? null : '/login';
    }

    return null;
  }
}
