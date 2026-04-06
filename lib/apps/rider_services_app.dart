import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/rider/rider_home_screen.dart';
import '../screens/rider_services/rider_services_signup_screen.dart';
import '../screens/service_worker/service_worker_home_screen.dart';
import 'common/app_providers.dart';
import 'common/role_auth_shell.dart';
import 'common/role_login_screens.dart';

class RiderServicesApp extends StatelessWidget {
  const RiderServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        title: '${AppStrings.appName} Rider Services',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const _RiderServicesSplash(),
          AppRoutes.login: (_) => const _RiderServicesLoginHub(),
          AppRoutes.riderHome: (_) => const RiderHomeScreen(),
          AppRoutes.serviceWorkerHome: (_) => const ServiceWorkerHomeScreen(),
          '/login-rider': (_) => const RiderLoginScreen(),
          '/login-home-services': (_) => const HomeServicesLoginScreen(),
          '/register': (_) => const RiderServicesSignupScreen(),
        },
      ),
    );
  }
}

class _RiderServicesSplash extends StatefulWidget {
  const _RiderServicesSplash();

  @override
  State<_RiderServicesSplash> createState() => _RiderServicesSplashState();
}

class _RiderServicesSplashState extends State<_RiderServicesSplash> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.checkAuthStatus();
    if (!mounted) return;

    if (!auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    if (auth.userType == UserType.rider) {
      Navigator.pushReplacementNamed(context, AppRoutes.riderHome);
      return;
    }
    if (auth.userType == UserType.serviceWorker) {
      Navigator.pushReplacementNamed(context, AppRoutes.serviceWorkerHome);
      return;
    }

    // Prevent cross-app session bleed.
    await auth.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}

class _RiderServicesLoginHub extends StatefulWidget {
  const _RiderServicesLoginHub();

  @override
  State<_RiderServicesLoginHub> createState() => _RiderServicesLoginHubState();
}

class _RiderServicesLoginHubState extends State<_RiderServicesLoginHub>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const _bodyPadding = EdgeInsets.fromLTRB(24, 36, 24, 36);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleAuthHeaderWithTabs(
            tabController: _tabController,
            topPadding: topPad,
            brandOverline: 'Rider Services',
            headline: 'Login & signup',
            subtitle: 'Delivery rider aur home technician ke liye',
            heroIcon: Icons.local_shipping_rounded,
            showBack: false,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: _bodyPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign in to your account',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pick your role to continue with phone login.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),
                      RoleHubOptionCard(
                        title: 'Rider',
                        subtitle: 'Deliveries, routes, and rider earnings',
                        icon: Icons.two_wheeler_rounded,
                        onTap: () =>
                            Navigator.pushNamed(context, '/login-rider'),
                      ),
                      const SizedBox(height: 14),
                      RoleHubOptionCard(
                        title: 'Home services',
                        subtitle:
                            'Technician jobs and home-service bookings',
                        icon: Icons.home_repair_service_rounded,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/login-home-services',
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: _bodyPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create your account',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Naya partner account — rider ya home technician. '
                        'Upar switch se role choose karein, phir form bharein.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          icon: const Icon(Icons.person_add_rounded),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Partner signup shuru karein',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

