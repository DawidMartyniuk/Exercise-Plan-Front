import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/screens/auth/login.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/utils/toast_untils.dart';

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

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage>
    with TickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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

      // ✅ TYMCZASOWO SYMULUJ SUKCES (USUŃ PO DODANIU LOGIKI)
      // await Future.delayed(Duration(seconds: 2));
      // final success = true; // Zmień na rzeczywisty wynik

      if (success) {
        ToastUtils.showSuccessToast(
          context: context,
          title: "Password Reset Successful!",
          message:
              "Your password has been reset successfully. You can now login with your new password.",
          duration: Duration(seconds: 4),
        );

        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => const LoginScreen()),
          );
        });
      } else {
        ToastUtils.showErrorToast(
          context: context,
          title: "Password Reset Failed",
          message:
              "There was an error resetting your password. Please try again.",
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      ToastUtils.showConnectionError(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getSafeTokenPreview(String token) {
    if (token.isEmpty) return "No token";
    if (token.length <= 10) return token;
    return "${token.substring(0, 10)}...";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 50),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(102),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),

                          // ✅ ANIMOWANY TYTUŁ
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1200),
                            tween: Tween(begin: 0.0, end: 4.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Text(
                                  "Set New Password",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 10),


                          const SizedBox(height: 30),

                          // ✅ ANIMOWANE POLE NOWE HASŁO
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 800),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(50 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: TextFormField(
                                    controller: _passwordController,
                                    keyboardType: TextInputType.visiblePassword,
                                    enabled: !_isLoading,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color:
                                            _isLoading
                                                ? Colors.grey
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed:
                                            _isLoading
                                                ? null
                                                : () {
                                                  setState(() {
                                                    _isPasswordVisible =
                                                        !_isPasswordVisible;
                                                  });
                                                },
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color:
                                              _isLoading
                                                  ? Colors.grey
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                        ),
                                      ),
                                      labelText: "New Password",
                                      labelStyle: TextStyle(
                                        color:
                                            _isLoading
                                                ? Colors.grey
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                      ),
                                      filled: true,
                                      fillColor:
                                          _isLoading
                                              ? Colors.grey.withAlpha(50)
                                              : Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                    ),
                                    style: TextStyle(
                                      color:
                                          _isLoading
                                              ? Colors.grey
                                              : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                    ),
                                    obscureText: !_isPasswordVisible,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a new password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      // ✅ DODATKOWE WALIDACJE
                                      if (!RegExp(
                                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                                      ).hasMatch(value)) {
                                        return 'Password must contain uppercase, lowercase and number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // ✅ ANIMOWANE POLE POTWIERDŹ HASŁO
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1000),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(-50 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: TextFormField(
                                    controller: _confirmPasswordController,
                                    keyboardType: TextInputType.visiblePassword,
                                    enabled: !_isLoading,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color:
                                            _isLoading
                                                ? Colors.grey
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed:
                                            _isLoading
                                                ? null
                                                : () {
                                                  setState(() {
                                                    _isConfirmPasswordVisible =
                                                        !_isConfirmPasswordVisible;
                                                  });
                                                },
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color:
                                              _isLoading
                                                  ? Colors.grey
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                        ),
                                      ),
                                      labelText: "Confirm Password",
                                      labelStyle: TextStyle(
                                        color:
                                            _isLoading
                                                ? Colors.grey
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                      ),
                                      filled: true,
                                      fillColor:
                                          _isLoading
                                              ? Colors.grey.withAlpha(50)
                                              : Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                    ),
                                    style: TextStyle(
                                      color:
                                          _isLoading
                                              ? Colors.grey
                                              : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                    ),
                                    obscureText: !_isConfirmPasswordVisible,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 15),

                          const SizedBox(height: 30),

                          // ✅ ANIMOWANE PRZYCISKI
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1400),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Wrap(
                                  spacing: 20,
                                  runSpacing: 10,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    // ✅ RESET PASSWORD BUTTON
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _isLoading
                                                ? Colors.grey
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        foregroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: _isLoading ? 0 : 5,
                                      ),
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : () => _resetPassword(context),
                                      child:
                                          _isLoading
                                              ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onPrimary,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text("Resetting..."),
                                                ],
                                              )
                                              : Text(
                                                "Reset Password",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      color:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary,
                                                    ),
                                              ),
                                    ),

                                    // ✅ CANCEL BUTTON
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        foregroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 5,
                                      ),
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : () {
                                                Navigator.of(
                                                  context,
                                                ).pushReplacement(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (ctx) =>
                                                            const LoginScreen(),
                                                  ),
                                                );
                                              },
                                      child: Text(
                                        "Cancel",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium!.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
