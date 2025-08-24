import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/authResponse.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';
import 'package:work_plan_front/screens/auth/register.dart';
import 'package:work_plan_front/screens/auth/reset_password.dart';
import 'package:work_plan_front/screens/auth/widget/email_field.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:work_plan_front/utils/toast_untils.dart'; // ✅ DODAJ IMPORT

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfAlreadyLoggedIn();
    });

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
      // ✅ UŻYJ ToastUtils
      ToastUtils.showValidationError(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // ✅ UŻYJ predefiniowanego toast-a
    ToastUtils.showLoginLoading(context);

    try {
      final loginResult = await ref
          .read(authProviderLogin.notifier)
          .login(email, password);
      
      if (!mounted) return; // ✅ DODAJ TO NA POCZĄTKU
      
      setState(() {
        _isLoading = false;
      });

      if (loginResult?.statusCode == 200 || loginResult?.statusCode == 201) {
        ref.read(exerciseProvider.notifier).fetchExercises(forceRefresh: true);
        
        // ✅ UŻYJ ToastUtils z imieniem użytkownika
        final userName = ref.read(authProviderLogin)?.user.name;
        ToastUtils.showLoginSuccess(context, userName: userName);
        
        await Future.delayed(Duration(milliseconds: 1500));
        
        if (!mounted) return; // ✅ DODAJ TO PRZED NAWIGACJĄ
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TabsScreen(selectedPageIndex: 0),
          ),
        );
      } else if (loginResult?.statusCode == 400) {
        if (!mounted) return; // ✅ DODAJ TO PRZED TOAST
        // ✅ UŻYJ ToastUtils z custom message
        ToastUtils.showLoginError(context, 
          customMessage: "Invalid email or password. Please try again.");
      } else {
        // ✅ UŻYJ ToastUtils dla błędu połączenia
        ToastUtils.showConnectionError(context);
      }
    } catch (e) {
      if (!mounted) return; // ✅ DODAJ TO PRZED setState
      setState(() {
        _isLoading = false;
      });
      print("Login error: $e");
      if (!mounted) return; // ✅ DODAJ TO PRZED TOAST
      // ✅ UŻYJ ToastUtils dla ogólnego błędu
      ToastUtils.showErrorToast(
        context: context,
        title: "Unexpected Error",
        message: "An unexpected error occurred. Please try again.",
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    // ✅ NASŁUCHUJ ZMIAN W STANIE AUTORYZACJI
    ref.listen<AuthResponse?>(authProviderLogin, (previous, next) {
      if (next != null && mounted) {
        // ✅ UŻYTKOWNIK SIĘ ZALOGOWAŁ - PRZEKIERUJ
        print("✅ Stan autoryzacji zmieniony - użytkownik zalogowany");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TabsScreen(selectedPageIndex: 0),
          ),
        );
      }
    });

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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
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
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Text(
                                  "Login",
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // ✅ ANIMOWANE POLE EMAIL
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 800),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(50 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: EmailField(emailController: _emailController)
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // ✅ ANIMOWANE POLE HASŁA
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1000),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(-50 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: TextFormField(
                                    keyboardType: TextInputType.visiblePassword,
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.outline,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      labelText: "Password",
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surface,
                                    ),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your password";
                                      }
                                      if (value.length < 4) {
                                        return "Password must be at least 4 characters long";
                                      }
                                      return null;
                                    },
                                    obscureText: !_isPasswordVisible,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 15),
                          
                          
                          // ✅ FORGOT PASSWORD z ToastUtils
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1200),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                       Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (ctx) => ResetPasswordScreen(),
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
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
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
