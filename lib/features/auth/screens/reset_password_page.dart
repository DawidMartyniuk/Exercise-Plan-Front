import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/features/auth/screens/login.dart';
import 'package:work_plan_front/provider/auth_provider.dart';
import 'package:work_plan_front/features/auth/widget/password_field.dart';
import 'package:work_plan_front/shared/utils/toast_untils.dart';
// ✅ NOWE IMPORTY ANIMACJI
import 'package:work_plan_front/features/auth/animation/animated_form_container.dart';
import 'package:work_plan_front/features/auth/animation/animation_button.dart';
import 'package:work_plan_front/features/auth/animation/animation_filed.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String email;
  final String token;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      ToastUtils.showValidationError(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref
          .read(authProviderResetPassword.notifier)
          .confirmPasswordReset(
            email: widget.email,
            token: widget.token,
            newPassword: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          );

      if (!mounted) return;

      if (success) {
        ToastUtils.showSuccessToast(
          context: context,
          title: "Password Reset Successful!",
          message: "Your password has been reset successfully. You can now login with your new password.",
          duration: Duration(seconds: 4),
        );

        Future.delayed(Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => const LoginScreen()),
          );
        });
      } else {
        ToastUtils.showErrorToast(
          context: context,
          title: "Password Reset Failed",
          message: "There was an error resetting your password. Please try again.",
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showConnectionError(context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 50),
          child: SingleChildScrollView( // ✅ DODAJ SCROLL VIEW
            child: AnimatedFormContainer( // ✅ UŻYJ NOWEGO KONTENERA
              title: "Set New Password",
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ INFO O EMAIL Z ANIMACJĄ
                    AnimatedField(
                      animationType: AnimationType.scaleIn,
                      delayMs: 600,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withAlpha(100),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Reset password for:",
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.email,
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ✅ NOWE HASŁO Z ANIMACJĄ
                    AnimatedField(
                      animationType: AnimationType.scaleIn,
                      delayMs: 800,
                      child: PasswordField(
                        passwordController: _passwordController,
                        isEnabled: !_isLoading,
                        isPasswordVisible: _isPasswordVisible,
                        labelText: "New Password",
                        isNewPassword: true, // ✅ SILNIEJSZA WALIDACJA
                        togglePasswordVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ✅ POTWIERDŹ HASŁO Z ANIMACJĄ
                    AnimatedField(
                      animationType: AnimationType.scaleIn,
                      delayMs: 1000,
                      child: PasswordField(
                        passwordController: _confirmPasswordController,
                        isEnabled: !_isLoading,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        labelText: "Confirm Password",
                        confirmPassword: _passwordController.text, // ✅ PORÓWNANIE
                        togglePasswordVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ✅ ANIMOWANE PRZYCISKI
                    AnimatedButton(
                      delayMs: 1400,
                      animationType: ButtonAnimationType.bounce,
                      buttons: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLoading
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: _isLoading ? 0 : 5,
                          ),
                          onPressed: _isLoading ? null : () => _resetPassword(context),
                          child: _isLoading
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Resetting...",
                                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  "Reset Password",
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (ctx) => const LoginScreen(),
                                    ),
                                  );
                                },
                          child: Text(
                            "Back to Login",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ),
                      ],
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
