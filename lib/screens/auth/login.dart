import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/authResponse.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';
import 'package:work_plan_front/screens/auth/animation/animated_form_container.dart';
import 'package:work_plan_front/screens/auth/animation/animation_button.dart';
import 'package:work_plan_front/screens/auth/animation/animation_filed.dart';
import 'package:work_plan_front/screens/auth/register.dart';
import 'package:work_plan_front/screens/auth/send_reset_password.dart';
import 'package:work_plan_front/screens/auth/widget/email_field.dart';
import 'package:work_plan_front/screens/auth/widget/password_field.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:work_plan_front/utils/toast_untils.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfAlreadyLoggedIn();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkIfAlreadyLoggedIn() {
    final authState = ref.read(authProviderLogin);
    if (authState != null) {
      print("✅ Użytkownik już zalogowany - przekierowuję do TabsScreen");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TabsScreen(selectedPageIndex: 0),
        ),
      );
    }
  }

  Future<void> _login(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (!_formKey.currentState!.validate()) {
      ToastUtils.showValidationError(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    ToastUtils.showLoginLoading(context);

    try {
      final loginResult = await ref
          .read(authProviderLogin.notifier)
          .login(email, password);
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });

      if (loginResult?.statusCode == 200 || loginResult?.statusCode == 201) {
        ref.read(exerciseProvider.notifier).fetchExercises(forceRefresh: true);
        
        final userName = ref.read(authProviderLogin)?.user.name;
        ToastUtils.showLoginSuccess(context, userName: userName);
        
        await Future.delayed(Duration(milliseconds: 1500));
        
        if (!mounted) return;
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TabsScreen(selectedPageIndex: 0),
          ),
        );
      } else if (loginResult?.statusCode == 400) {
        if (!mounted) return;
        ToastUtils.showLoginError(context, 
          customMessage: "Invalid email or password. Please try again.");
      } else {
        ToastUtils.showConnectionError(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      print("Login error: $e");
      if (!mounted) return;
      ToastUtils.showErrorToast(
        context: context,
        title: "Unexpected Error",
        message: "An unexpected error occurred. Please try again.",
      );
    }
  }

  void showPasswordText() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthResponse?>(authProviderLogin, (previous, next) {
      if (next != null && mounted) {
        print("✅ Stan autoryzacji zmieniony - użytkownik zalogowany");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TabsScreen(selectedPageIndex: 0),
          ),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 50), // ✅ DODAJ PADDING
          child: SingleChildScrollView(
            child: AnimatedFormContainer(
              title: "Login",
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ EMAIL FIELD Z ANIMACJĄ
                    AnimatedField(
                      animationType: AnimationType.scaleIn,
                      delayMs: 800,
                      child: EmailField(
                        emailController: _emailController,
                        isEnabled: !_isLoading,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // ✅ PASSWORD FIELD Z ANIMACJĄ
                    AnimatedField(
                      animationType: AnimationType.scaleIn,
                      delayMs: 1000,
                      child: PasswordField(
                        passwordController: _passwordController,
                        isPasswordVisible: _isPasswordVisible,
                        isEnabled: !_isLoading,
                        togglePasswordVisibility: showPasswordText,
                      ),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // ✅ FORGOT PASSWORD Z ANIMACJĄ
                    AnimatedField(
                      animationType: AnimationType.scaleIn,
                      delayMs: 1200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => SendResetPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Forgot Password",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // ✅ BUTTONS Z ANIMACJĄ
                    AnimatedButton(
                      delayMs: 1400,
                      animationType: ButtonAnimationType.bounce,
                      buttons: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          onPressed: _isLoading ? null : () => _login(context),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  "Login Account",
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
                              horizontal: 16,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Create Account",
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
