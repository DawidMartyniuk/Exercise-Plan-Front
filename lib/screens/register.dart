import 'package:flutter/material.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/screens/login.dart';
import 'dart:io';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _profileImage;

 

  Future<void> register(BuildContext contex) async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final repeatPassword = _confirmPasswordController.text;

    if (!_formKey.currentState!.validate()) {
      return;
    } else {
      try {
        await ref
            .read(authProviderRegister.notifier)
            .register(name, email, password, repeatPassword);

        print("Zarejestrowano $name i  $email i $password i $repeatPassword");
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => LoginScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 50),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 30),
                      Text(
                        "Create Account",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {},
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                          child:
                              _profileImage == null
                                  ? Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Name",
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter your name';
                          }
                          if (value.length < 3) {
                            return 'Name must be at least 3 characters long';
                          }
                        },
                      ),
                      SizedBox(height: 30),
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
                      SizedBox(height: 30),
                      TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
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
                          if (value == null) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          final containsUpperCase = value.contains(
                            RegExp(r'[A-Z]'),
                          );
                          if (!containsUpperCase) {
                            return 'Password must contain at least one uppercase latter';
                          }
                          if (_passwordController.text !=
                              _confirmPasswordController.text) {
                            return 'Passwords is not the same';
                          }
                        },
                        obscureText: true,
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        controller: _confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          labelText: "Repead Password",
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          final containsUpperCase = value.contains(
                            RegExp(r'[A-Z]'),
                          );
                          if (!containsUpperCase) {
                            return 'Password must contain at least one uppercase latter';
                          }
                          if (_passwordController.text !=
                              _confirmPasswordController.text) {
                            return 'Passwords is not the same';
                          }
                        },
                        obscureText: true,
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => LoginScreen(),
                                ),
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
                                  "cancel",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium!.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              register(context);
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
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
      ),
    );
  }
}
