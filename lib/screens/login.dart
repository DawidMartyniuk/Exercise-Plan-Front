import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/authResponse.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/screens/register.dart';
import 'package:work_plan_front/screens/start.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});


 @override
  _LoginScreenState createState() => _LoginScreenState(); 
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login(BuildContext context)async {
    final email = _emailController.text;
    final password = _passwordController.text;
    if (!_formKey.currentState!.validate()) {
      return; 
    }
    else {
     await ref.read(authProvider.notifier).login(email, password);
    print("zalogowano na $email i $password");
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => Startscreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authResponse = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 50),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
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
                    SizedBox(height: 20),
                    Text(
                      "Login ",
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        labelText: "Email",
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      validator: (value) {
                        if(value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if(!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        labelText: "Password",
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      validator: (value) {
                        if(value == null){
                          return "Please enter your password";
                        }
                        if(value.length < 4) {
                          return "Password must be at least 6 characters long";
                        } 
                        final containsUpperCase = value.contains(RegExp(r'[A-Z]'));
                        if(!containsUpperCase) {
                          return "Password must contain at least one uppercase letter";
                        }
                      },
                      obscureText: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot Password ",
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 20, 
                      runSpacing: 10, 
                      alignment: WrapAlignment.center,

                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                
                            _login(context);
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.fromARGB(255, 239, 64, 64),
                                  Color.fromARGB(255, 247, 87, 75),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Container(
                               padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Login Account",
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              
                            ),
                          ),
                        ),
                        SizedBox(width: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => RegisterScreen()),
                            );
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.fromARGB(255, 239, 64, 64),
                                  Color.fromARGB(255, 247, 87, 75),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Create Account",
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
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
