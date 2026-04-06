import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../apps/common/role_auth_shell.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/async_guard.dart';
import '../../providers/auth_provider.dart' show AuthProvider, UserType;
import '../auth/login/login_constants.dart';
import '../auth/login/signup_form.dart';

/// Sign-up **only** for delivery rider + home technician — not the full BizzWay
/// business/customer app. Uses same [AuthProvider] logic as main [LoginScreen].
class RiderServicesSignupScreen extends StatefulWidget {
  const RiderServicesSignupScreen({super.key});

  @override
  State<RiderServicesSignupScreen> createState() =>
      _RiderServicesSignupScreenState();
}

class _RiderServicesSignupScreenState extends State<RiderServicesSignupScreen> {
  final _signupFormKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final _nameCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _workerNicCtrl = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _workerImage;
  XFile? _riderLicenseImage;
  XFile? _riderNicImage;
  String _selectedProfession = 'Electrician';
  String _selectedWorkerPlan = 'monthly';

  ServiceBranch _signupServiceBranch = ServiceBranch.home;

  final _riderLicenseCtrl = TextEditingController();
  final _riderNicCtrl = TextEditingController();
  final _riderBikeCtrl = TextEditingController();
  String _selectedRiderPlan = 'rider_monthly';
  bool _riderAgreeMinWallet = false;

  /// Always partner flow (rider app has no business/customer signup here).
  static const UserType _userType = UserType.serviceWorker;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPasswordCtrl.dispose();
    _phoneCtrl.dispose();
    _areaCtrl.dispose();
    _workerNicCtrl.dispose();
    _riderLicenseCtrl.dispose();
    _riderNicCtrl.dispose();
    _riderBikeCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_signupFormKey.currentState?.validate() != true) return;
    final auth = context.read<AuthProvider>();
    final isWorker =
        _userType == UserType.serviceWorker &&
        _signupServiceBranch == ServiceBranch.home;
    final isRider =
        _userType == UserType.serviceWorker &&
        _signupServiceBranch == ServiceBranch.rider;
    if (_isSubmitting) return;
    if (isWorker && _workerImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add profile image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (isRider) {
      if (_riderLicenseImage == null || _riderNicImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Driving license aur CNIC dono ki clear photo upload karein.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (!_riderAgreeMinWallet) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Neeche diye gaye box par tick karein: Rs 5,000 ka wada.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (_riderLicenseCtrl.text.trim().length < 4 ||
          _riderNicCtrl.text.trim().length < 13 ||
          _riderBikeCtrl.text.trim().length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('License, CNIC aur bike number sahi bharein'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }
    setState(() => _isSubmitting = true);
    try {
      final success = await AsyncGuard.withTimeout(
        auth.signUp(
          _phoneCtrl.text,
          '',
          userType: isRider ? UserType.rider : _userType,
        ),
      );
      if (!mounted) return;
      if (success) {
        if (isRider) {
          await auth.setRiderProfile(
            licenseNo: _riderLicenseCtrl.text.trim(),
            nic: _riderNicCtrl.text.trim(),
            bikeNumber: _riderBikeCtrl.text.trim(),
            walletAmount: 5000,
            planId: _selectedRiderPlan,
            licenseImagePath: _riderLicenseImage!.path,
            nicImagePath: _riderNicImage!.path,
          );
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, AppRoutes.riderHome);
        } else if (isWorker) {
          await auth.setServiceWorkerProfile(
            profession: _selectedProfession,
            nic: _workerNicCtrl.text.trim(),
            imagePath: _workerImage!.path,
            plan: _selectedWorkerPlan,
          );
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, AppRoutes.serviceWorkerHome);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AsyncGuard.friendlyMessage(e)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickWorkerImage() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 75,
      );
      if (file == null || !mounted) return;
      setState(() => _workerImage = file);
    } catch (e, st) {
      debugPrint('ImagePicker worker: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Photo select nahi ho saki. Settings → App → Photos / Files permission check karein.\n(${e.toString()})',
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _pickRiderDocImage({required bool setLicense}) async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 82,
      );
      if (file == null || !mounted) return;
      setState(() {
        if (setLicense) {
          _riderLicenseImage = file;
        } else {
          _riderNicImage = file;
        }
      });
    } catch (e, st) {
      debugPrint('ImagePicker rider doc: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gallery nahi khuli. App ko Photos / Storage ki permission dein, phir dubara try karein.\n(${e.toString()})',
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoleAuthShell(
      brandOverline: 'Rider Services',
      headline: 'Naya account',
      subtitle: 'Delivery rider ya home technician — yahi app, poora flow',
      heroIcon: Icons.how_to_reg_rounded,
      showBack: true,
      wrapContentInCard: false,
      child: SignupForm(
        formKey: _signupFormKey,
        nameCtrl: _nameCtrl,
        phoneCtrl: _phoneCtrl,
        areaCtrl: _areaCtrl,
        signupEmailCtrl: _signupEmailCtrl,
        signupPasswordCtrl: _signupPasswordCtrl,
        workerNicCtrl: _workerNicCtrl,
        riderLicenseCtrl: _riderLicenseCtrl,
        riderNicCtrl: _riderNicCtrl,
        riderBikeCtrl: _riderBikeCtrl,
        workerImage: _workerImage,
        riderLicenseImage: _riderLicenseImage,
        riderNicImage: _riderNicImage,
        selectedUserType: _userType,
        onUserTypeChanged: (_) {},
        signupServiceBranch: _signupServiceBranch,
        onSignupServiceBranchChanged: (b) =>
            setState(() => _signupServiceBranch = b),
        selectedProfession: _selectedProfession,
        onProfessionChanged: (v) => setState(() => _selectedProfession = v),
        selectedWorkerPlan: _selectedWorkerPlan,
        onWorkerPlanChanged: (v) => setState(() => _selectedWorkerPlan = v),
        selectedRiderPlan: _selectedRiderPlan,
        onRiderPlanChanged: (v) => setState(() => _selectedRiderPlan = v),
        riderAgreeMinWallet: _riderAgreeMinWallet,
        onRiderAgreeToggle: () => setState(
          () => _riderAgreeMinWallet = !_riderAgreeMinWallet,
        ),
        onRiderAgreeCheckbox: (v) =>
            setState(() => _riderAgreeMinWallet = v ?? false),
        onPickWorkerImage: _pickWorkerImage,
        onPickRiderLicenseImage: () =>
            _pickRiderDocImage(setLicense: true),
        onPickRiderNicImage: () => _pickRiderDocImage(setLicense: false),
        onSignUp: _signUp,
        isSubmitting: _isSubmitting,
        onSwitchToLogin: () => Navigator.of(context).pop(),
        riderServicesMode: true,
      ),
    );
  }
}
