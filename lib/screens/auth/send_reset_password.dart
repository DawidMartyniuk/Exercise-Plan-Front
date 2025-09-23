import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/screens/auth/login.dart';
import 'package:work_plan_front/provider/auth_provider.dart';
import 'package:work_plan_front/screens/auth/widget/email_field.dart';
import 'package:work_plan_front/utils/toast_untils.dart';
// ✅ NOWE IMPORTY ANIMACJI
import 'package:work_plan_front/screens/auth/animation/animated_form_container.dart';
import 'package:work_plan_front/screens/auth/animation/animation_button.dart';
import 'package:work_plan_front/screens/auth/animation/animation_filed.dart';

class SendResetPasswordScreen extends ConsumerStatefulWidget {
  const SendResetPasswordScreen({super.key});

  @override
  _SendResetPasswordState createState() => _SendResetPasswordState();
}

class _SendResetPasswordState extends ConsumerState<SendResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await ref
            .read(authProviderResetPassword.notifier)
            .resetPassword(_emailController.text.trim());

        if (!mounted) return;

        if (success) {
          ToastUtils.showSuccessToast(
            context: context,
            message: 'Reset link sent to ${_emailController.text}',
            duration: Duration(seconds: 3),
          );
          Future.delayed(Duration(seconds: 3), () {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const LoginScreen()),
            );
          });
        } else {
          ToastUtils.showErrorToast(
            context: context,
            message: 'Failed to send reset link. Please try again later.',
            duration: Duration(seconds: 3),
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
    } else {
      ToastUtils.showErrorToast(
        context: context,
        message: 'Please enter a valid email address.',
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // ✅ DODAJ TŁO
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 50),
          child: SingleChildScrollView( // ✅ DODAJ SCROLL VIEW
            child: AnimatedFormContainer( // ✅ UŻYJ NOWEGO KONTENERA
              title: "Reset Password",
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ INFORMACJA Z ANIMACJĄ
                    AnimatedField(
                      animationType: AnimationType.scaleIn,
                      delayMs: 600,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
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
                              child: Text(
                                "Enter your email address and we'll send you a link to reset your password.",
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // ✅ EMAIL FIELD Z ANIMACJĄ
                    AnimatedField(
                      animationType: AnimationType.scaleIn,
                      delayMs: 800,
                      child: EmailField(
                        emailController: _emailController,
                        isEnabled: !_isLoading,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ✅ BUTTONS Z ANIMACJĄ
                    AnimatedButton(
                      delayMs: 1200,
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
                                      "Sending...",
                                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  "Send Reset Link",
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