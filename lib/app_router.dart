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

// REPOSITORIES
import 'data/repositories/auth_repository.dart';

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
        GoRoute(path: '/',                  builder: (_, __) => const OnboardingHomePage()),
        GoRoute(path: '/onboarding/home',   builder: (_, __) => const OnboardingHomePage()),
        GoRoute(path: '/onboarding/1',      builder: (_, __) => const OnboardingPage()),
        GoRoute(path: '/onboarding/2',      builder: (_, __) => const OnboardingPage()),
        GoRoute(path: '/onboarding/3',      builder: (_, __) => const OnboardingPage()),
        GoRoute(path: '/login',             builder: (_, __) => const LoginPage()),
        GoRoute(path: '/signup',            builder: (_, __) => const SignupPage()),
        GoRoute(path: '/forgot-password',   builder: (_, __) => const ForgotPasswordPage()),

        // Dashboard
        GoRoute(path: '/dashboard/home',          builder: (_, __) => const HomePage()),
        GoRoute(path: '/dashboard/jobs',          builder: (_, __) => const ViewJobsPage()),
        GoRoute(path: '/dashboard/post-job',      builder: (_, __) => const PostJobPage()),
        GoRoute(path: '/dashboard/applications',  builder: (_, __) => const ApplicationsPage()),
        GoRoute(path: '/dashboard/settings',      builder: (context, _) {
          final themeProvider = ThemeProvider.of(context);
          return SettingsPage(onToggleTheme: themeProvider.toggleTheme);
        }),
        GoRoute(path: '/dashboard/notifications', builder: (_, __) => const NotificationPage()),
        GoRoute(path: '/dashboard/my-jobs',       builder: (_, __) => const MyJobsPage()),
        GoRoute(path: '/dashboard/apply-jobs',    builder: (_, __) => const ApplyJobsPage()),
        GoRoute(path: '/dashboard/my-cv',         builder: (_, __) => const MyCvPage()),
        GoRoute(path: '/dashboard/fixit-assistance', builder: (_, __) => const FixitAssistancePage()),
        GoRoute(path: '/dashboard/subscription',  builder: (_, __) => const SubscriptionPage()),
        GoRoute(path: '/dashboard/view-jobs',     builder: (_, __) => const ViewJobsPage()),
        GoRoute(path: '/subscription',            builder: (_, __) => const SubscriptionPage()),
        GoRoute(path: '/dashboard/about',         builder: (_, __) => const AboutPage()),
        GoRoute(
          path: '/dashboard/job-applicants/:jobId',
          builder: (_, state) => JobApplicantsPage(
            jobId:    state.pathParameters['jobId'] ?? '',
            jobTitle: state.extra as String? ?? 'Job',
          ),
        ),
      ],
    );
  }
}
