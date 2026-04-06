import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/async_guard.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'role_auth_shell.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final auth = context.read<AuthProvider>();
      final ok = await AsyncGuard.withTimeout(
        auth.loginWithPhone(_phoneCtrl.text.trim(), phoneRole: UserType.customer),
      );
      if (!mounted) return;
      if (ok) {
        Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
      } else {
        _snack('Invalid phone number');
      }
    } catch (e) {
      if (!mounted) return;
      _snack(AsyncGuard.friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleAuthShell(
      headline: 'Customer',
      subtitle: 'Sign in with your registered mobile number',
      heroIcon: Icons.person_rounded,
      showBack: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign in',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'We’ll use your phone to verify your account.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            CustomTextField(
              label: AppStrings.phone,
              hint: '03XX XXXXXXX',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (v) =>
                  (v ?? '').trim().length >= 10 ? null : 'Enter a valid phone number',
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Continue',
              onPressed: _busy ? null : _submit,
              isLoading: _busy,
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessLoginScreen extends StatefulWidget {
  const BusinessLoginScreen({super.key});

  @override
  State<BusinessLoginScreen> createState() => _BusinessLoginScreenState();
}

class _BusinessLoginScreenState extends State<BusinessLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final auth = context.read<AuthProvider>();
      final ok = await AsyncGuard.withTimeout(
        auth.login(_emailCtrl.text.trim(), _passwordCtrl.text),
      );
      if (!mounted) return;
      if (!ok) {
        _snack('Invalid credentials');
        return;
      }

      final business = context.read<BusinessProvider>();
      await AsyncGuard.withTimeout(business.loadBusiness());
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        business.selectedBusiness == null
            ? AppRoutes.businessSelection
            : AppRoutes.dashboard,
      );
    } catch (e) {
      if (!mounted) return;
      _snack(AsyncGuard.friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleAuthShell(
      headline: 'Business owner',
      subtitle: 'Sign in with your owner email and password',
      heroIcon: Icons.store_rounded,
      showBack: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign in',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Secure access to your dashboard and business tools.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            CustomTextField(
              label: AppStrings.email,
              hint: 'you@company.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Enter your email';
                if (!s.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: AppStrings.password,
              hint: '••••••••',
              controller: _passwordCtrl,
              isPassword: true,
              prefixIcon: Icons.lock_outline_rounded,
              validator: (v) =>
                  (v ?? '').length >= 6 ? null : 'At least 6 characters',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(AppStrings.forgotPassword),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: AppStrings.login,
              onPressed: _busy ? null : _submit,
              isLoading: _busy,
            ),
          ],
        ),
      ),
    );
  }
}

class RiderLoginScreen extends StatefulWidget {
  const RiderLoginScreen({super.key});

  @override
  State<RiderLoginScreen> createState() => _RiderLoginScreenState();
}

class _RiderLoginScreenState extends State<RiderLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final auth = context.read<AuthProvider>();
      final ok = await AsyncGuard.withTimeout(
        auth.loginWithPhone(_phoneCtrl.text.trim(), phoneRole: UserType.rider),
      );
      if (!mounted) return;
      if (ok) {
        Navigator.pushReplacementNamed(context, AppRoutes.riderHome);
      } else {
        _snack('Invalid phone number');
      }
    } catch (e) {
      if (!mounted) return;
      _snack(AsyncGuard.friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleAuthShell(
      headline: 'Rider',
      subtitle: 'Delivery access — sign in with your registered number',
      heroIcon: Icons.two_wheeler_rounded,
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign in',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Use the same mobile number you used during onboarding.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            CustomTextField(
              label: AppStrings.phone,
              hint: '03XX XXXXXXX',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (v) =>
                  (v ?? '').trim().length >= 10 ? null : 'Enter a valid phone number',
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Continue',
              onPressed: _busy ? null : _submit,
              isLoading: _busy,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeServicesLoginScreen extends StatefulWidget {
  const HomeServicesLoginScreen({super.key});

  @override
  State<HomeServicesLoginScreen> createState() => _HomeServicesLoginScreenState();
}

class _HomeServicesLoginScreenState extends State<HomeServicesLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final auth = context.read<AuthProvider>();
      final ok = await AsyncGuard.withTimeout(
        auth.loginWithPhone(
          _phoneCtrl.text.trim(),
          phoneRole: UserType.serviceWorker,
        ),
      );
      if (!mounted) return;
      if (ok) {
        Navigator.pushReplacementNamed(context, AppRoutes.serviceWorkerHome);
      } else {
        _snack('Invalid phone number');
      }
    } catch (e) {
      if (!mounted) return;
      _snack(AsyncGuard.friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleAuthShell(
      headline: 'Home services',
      subtitle: 'Technician access — sign in with your registered number',
      heroIcon: Icons.home_repair_service_rounded,
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign in',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Use the mobile number linked to your service worker profile.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            CustomTextField(
              label: AppStrings.phone,
              hint: '03XX XXXXXXX',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (v) =>
                  (v ?? '').trim().length >= 10 ? null : 'Enter a valid phone number',
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Continue',
              onPressed: _busy ? null : _submit,
              isLoading: _busy,
            ),
          ],
        ),
      ),
    );
  }
}
