import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/screens/login.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/utils/toast_untils.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends ConsumerState<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    _emailController.dispose();
    // _passwordController.dispose();
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

        if (success) {
          ToastUtils.showSuccessToast(
            context: context,
            message: 'Reset link sent to ${_emailController.text}',
            duration: Duration(seconds: 3),
          );
          Future.delayed(Duration(seconds: 3), () {
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
        ToastUtils.showConnectionError(context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }

      // setState(() {
      //   _isLoading = false;
      // });
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 50.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(102),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
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

                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1200),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Text(
                                  "Reset Password",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 800),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(50 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
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
                                        Icons.email,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                      labelText: "Email",
                                      labelStyle: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                      filled: true,
                                      fillColor:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      final emailRegex = RegExp(
                                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                      );
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 25),

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
                                                  Text("Sending..."),
                                                ],
                                              )
                                              : Text(
                                                "Send Reset Link",
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
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (ctx) => const LoginScreen(),
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
