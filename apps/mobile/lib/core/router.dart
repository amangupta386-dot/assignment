import "package:go_router/go_router.dart";
import "../features/auth/presentation/login_screen.dart";
import "../features/workers/presentation/nearby_workers_screen.dart";
import "../features/jobs/presentation/create_job_screen.dart";
import "../features/jobs/presentation/track_job_screen.dart";
import "../features/payments/presentation/payment_screen.dart";
import "../features/ratings/presentation/rating_screen.dart";
import "../features/profile/presentation/profile_screen.dart";

final appRouter = GoRouter(
  initialLocation: "/login",
  routes: [
    GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
    GoRoute(path: "/workers", builder: (context, state) => const NearbyWorkersScreen()),
    GoRoute(path: "/jobs/create", builder: (context, state) => const CreateJobScreen()),
    GoRoute(path: "/jobs/track", builder: (context, state) => const TrackJobScreen()),
    GoRoute(path: "/payment", builder: (context, state) => const PaymentScreen()),
    GoRoute(path: "/rating", builder: (context, state) => const RatingScreen()),
    GoRoute(path: "/profile", builder: (context, state) => const ProfileScreen())
  ]
);
