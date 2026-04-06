import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import 'login_constants.dart';
import 'rider_signup_widgets.dart';
import 'service_branch_switcher.dart';
import 'user_type_cards.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.areaCtrl,
    required this.signupEmailCtrl,
    required this.signupPasswordCtrl,
    required this.workerNicCtrl,
    required this.riderLicenseCtrl,
    required this.riderNicCtrl,
    required this.riderBikeCtrl,
    required this.workerImage,
    required this.riderLicenseImage,
    required this.riderNicImage,
    required this.selectedUserType,
    required this.onUserTypeChanged,
    required this.signupServiceBranch,
    required this.onSignupServiceBranchChanged,
    required this.selectedProfession,
    required this.onProfessionChanged,
    required this.selectedWorkerPlan,
    required this.onWorkerPlanChanged,
    required this.selectedRiderPlan,
    required this.onRiderPlanChanged,
    required this.riderAgreeMinWallet,
    required this.onRiderAgreeToggle,
    required this.onRiderAgreeCheckbox,
    required this.onPickWorkerImage,
    required this.onPickRiderLicenseImage,
    required this.onPickRiderNicImage,
    required this.onSignUp,
    required this.isSubmitting,
    required this.onSwitchToLogin,
    this.riderServicesMode = false,
  });

  /// Rider Services app: only partner signup (home tech vs rider), polished UI.
  final bool riderServicesMode;

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController areaCtrl;
  final TextEditingController signupEmailCtrl;
  final TextEditingController signupPasswordCtrl;
  final TextEditingController workerNicCtrl;
  final TextEditingController riderLicenseCtrl;
  final TextEditingController riderNicCtrl;
  final TextEditingController riderBikeCtrl;
  final XFile? workerImage;
  final XFile? riderLicenseImage;
  final XFile? riderNicImage;
  final UserType selectedUserType;
  final ValueChanged<UserType> onUserTypeChanged;
  final ServiceBranch signupServiceBranch;
  final ValueChanged<ServiceBranch> onSignupServiceBranchChanged;
  final String selectedProfession;
  final ValueChanged<String> onProfessionChanged;
  final String selectedWorkerPlan;
  final ValueChanged<String> onWorkerPlanChanged;
  final String selectedRiderPlan;
  final ValueChanged<String> onRiderPlanChanged;
  final bool riderAgreeMinWallet;
  final VoidCallback onRiderAgreeToggle;
  final ValueChanged<bool?> onRiderAgreeCheckbox;
  final VoidCallback onPickWorkerImage;
  final VoidCallback onPickRiderLicenseImage;
  final VoidCallback onPickRiderNicImage;
  final VoidCallback onSignUp;
  final bool isSubmitting;
  final VoidCallback onSwitchToLogin;

  @override
  Widget build(BuildContext context) {
    final isWorker = selectedUserType == UserType.serviceWorker &&
        signupServiceBranch == ServiceBranch.home;
    final isRider = selectedUserType == UserType.serviceWorker &&
        signupServiceBranch == ServiceBranch.rider;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (riderServicesMode) ...[
            const PartnerSignupHeroHeader(),
            const SizedBox(height: 18),
            const Text(
              'Aap kis partner type hain?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ServiceBranchSwitcher(
              value: signupServiceBranch,
              onChanged: onSignupServiceBranchChanged,
            ),
            const SizedBox(height: 18),
          ] else ...[
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose your account type to get started',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text(
              'I am a...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                UserTypeToggleCard(
                  title: 'Business Owner',
                  subtitle: 'Manage your business',
                  isSelected: selectedUserType == UserType.businessOwner,
                  onTap: () => onUserTypeChanged(UserType.businessOwner),
                ),
                const SizedBox(width: 8),
                UserTypeToggleCard(
                  title: 'Customer',
                  subtitle: 'Book services nearby',
                  isSelected: selectedUserType == UserType.customer,
                  onTap: () => onUserTypeChanged(UserType.customer),
                ),
                const SizedBox(width: 8),
                UserTypeToggleCard(
                  title: 'Service',
                  subtitle: 'Get nearby jobs',
                  isSelected: selectedUserType == UserType.serviceWorker,
                  onTap: () => onUserTypeChanged(UserType.serviceWorker),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (selectedUserType == UserType.serviceWorker) ...[
              ServiceBranchSwitcher(
                value: signupServiceBranch,
                onChanged: onSignupServiceBranchChanged,
              ),
              const SizedBox(height: 10),
            ],
          ],
          CustomTextField(
            label: 'Full Name',
            hint: 'e.g. Muhammad Ali Khan',
            controller: nameCtrl,
            prefixIcon: Icons.person_outline,
            validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 10),
          if (selectedUserType == UserType.customer) ...[
            CustomTextField(
              label: 'Phone Number',
              hint: '03XX XXXXXXX',
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (v) =>
                  v!.isEmpty ? 'Please enter your phone number' : null,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              label: 'Area / Location',
              hint: 'e.g. Defence, Lahore',
              controller: areaCtrl,
              prefixIcon: Icons.location_on_outlined,
              validator: (v) => v!.isEmpty ? 'Please enter your area' : null,
            ),
          ] else ...[
            if (isWorker) ...[
              if (riderServicesMode) ...[
                const SignupSubsectionHeader(
                  icon: Icons.handyman_rounded,
                  title: 'Technician profile',
                  subtitle:
                      'Photo, CNIC aur skill — customers ko clear identity dikhe.',
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  GestureDetector(
                    onTap: onPickWorkerImage,
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        image: workerImage == null
                            ? null
                            : DecorationImage(
                                image: FileImage(File(workerImage!.path)),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: workerImage == null
                          ? const Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      workerImage == null
                          ? 'Add profile photo'
                          : 'Photo selected',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Phone Number',
                hint: '03XX XXXXXXX',
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (v) =>
                    v!.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'CNIC Number',
                hint: '12345-1234567-1',
                controller: workerNicCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.badge_outlined,
                validator: (v) =>
                    v!.isEmpty ? 'Please enter CNIC number' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                key: ValueKey<String>(selectedProfession),
                initialValue: selectedProfession,
                items: kWorkerProfessions
                    .map(
                      (p) => DropdownMenuItem<String>(
                        value: p,
                        child: Text(p),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onProfessionChanged(v);
                },
                decoration: InputDecoration(
                  labelText: 'Profession',
                  prefixIcon: const Icon(Icons.handyman_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  riderServicesMode ? 'Subscription plan' : 'Subscription Plan',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              ...kWorkerPlans.map((p) {
                final selected = selectedWorkerPlan == p.id;
                return GestureDetector(
                  onTap: () => onWorkerPlanChanged(p.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryLight
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                p.subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          p.saveText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ] else if (isRider) ...[
              if (riderServicesMode) ...[
                const SizedBox(height: 8),
                const RiderSignupStepsStrip(),
                const SizedBox(height: 18),
                const SignupSubsectionHeader(
                  icon: Icons.phone_android_rounded,
                  title: 'Contact',
                  subtitle: 'Yeh number login aur orders ke updates ke liye use hoga.',
                ),
                const SizedBox(height: 12),
              ],
              CustomTextField(
                label: 'Phone Number',
                hint: '03XX XXXXXXX',
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (v) =>
                    v!.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 14),
              if (riderServicesMode) ...[
                const SignupSubsectionHeader(
                  icon: Icons.directions_bike_rounded,
                  title: 'Driving & vehicle',
                  subtitle:
                      'License aur CNIC ki clear photos — driving side pe focus.',
                ),
                const SizedBox(height: 12),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RiderDocPickerTile(
                      label: 'Driving license (photo)',
                      hint: riderServicesMode
                          ? 'Front · readable numbers'
                          : null,
                      file: riderLicenseImage,
                      onTap: onPickRiderLicenseImage,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RiderDocPickerTile(
                      label: 'CNIC (photo)',
                      hint: riderServicesMode ? 'Front side · sharp' : null,
                      file: riderNicImage,
                      onTap: onPickRiderNicImage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Driving license number',
                hint: riderServicesMode
                    ? 'Card jaisa number (LTV / motorcycle)'
                    : 'License / LTV as per card',
                controller: riderLicenseCtrl,
                prefixIcon: Icons.badge_rounded,
                validator: (v) => (v ?? '').trim().length < 4
                    ? 'Enter your license number'
                    : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'CNIC',
                hint: '12345-1234567-1',
                controller: riderNicCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.badge_outlined,
                validator: (v) =>
                    (v ?? '').trim().length < 13 ? 'Enter a valid CNIC' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Bike registration number',
                hint: riderServicesMode
                    ? 'e.g. LHR-1234 (apni bike ka)'
                    : 'e.g. KHI-1234',
                controller: riderBikeCtrl,
                prefixIcon: Icons.two_wheeler_rounded,
                validator: (v) =>
                    (v ?? '').trim().length < 2 ? 'Enter bike registration' : null,
              ),
              const SizedBox(height: 12),
              RiderWalletAgreementCard(
                agree: riderAgreeMinWallet,
                onToggle: onRiderAgreeToggle,
                onCheckboxChanged: onRiderAgreeCheckbox,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  riderServicesMode ? 'Choose your plan' : 'Rider subscription',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ...kRiderPlans.map((p) {
                final selected = selectedRiderPlan == p.id;
                return GestureDetector(
                  onTap: () => onRiderPlanChanged(p.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryLight
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                p.subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          p.badge,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ] else ...[
              CustomTextField(
                label: AppStrings.email,
                hint: 'you@email.com',
                controller: signupEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) =>
                    v!.isEmpty ? 'Please enter your email' : null,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: AppStrings.password,
                hint: 'At least 6 characters (letters + numbers)',
                controller: signupPasswordCtrl,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (v) =>
                    v!.length < 6 ? 'Min 6 characters required' : null,
              ),
            ],
          ],
          const SizedBox(height: 20),
          Consumer<AuthProvider>(
            builder: (context, auth, _) => CustomButton(
              label: AppStrings.signUp,
              onPressed: onSignUp,
              isLoading: auth.isLoading || isSubmitting,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: onSwitchToLogin,
              child: RichText(
                text: const TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
