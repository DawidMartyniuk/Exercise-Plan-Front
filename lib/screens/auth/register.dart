import 'dart:math';
import 'package:flutter/material.dart';
import 'package:work_plan_front/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/screens/auth/animation/animated_form_container.dart';
import 'package:work_plan_front/screens/auth/animation/animation_button.dart';
import 'package:work_plan_front/screens/auth/animation/animation_filed.dart';
import 'package:work_plan_front/screens/auth/login.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:work_plan_front/screens/auth/widget/email_field.dart';
import 'package:work_plan_front/screens/auth/widget/name_field.dart';
import 'package:work_plan_front/screens/auth/widget/password_field.dart';

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
  final ImagePicker _picker = ImagePicker();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Center(
            child: Text(
              'Select Image Source',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        print("Wybrano obraz: ${_profileImage!.path}");
      }
    } catch (e) {
      print("Błąd podczas wybierania obrazu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> register(BuildContext context) async {
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

        print("Zarejestrowano $name i $email i $password i $repeatPassword");
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => LoginScreen()),
        );
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
      backgroundColor: Theme.of(context).colorScheme.surface, // ✅ DODAJ TŁO
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 50),
          child: SingleChildScrollView(
            child: AnimatedFormContainer( // ✅ TERAZ BEZ SCAFFOLD
              title: "Create Account",
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ PROFILE IMAGE
                    AnimatedField(
                      animationType: AnimationType.scaleIn,
                      delayMs: 600,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null
                              ? Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // ✅ NAME FIELD
                    AnimatedField(
                      animationType: AnimationType.slideLeft,
                      delayMs: 800,
                      child: NameField(nameController: _nameController),
                    ),
                    
                    const SizedBox(height: 30),

                    // ✅ EMAIL FIELD
                    AnimatedField(
                      animationType: AnimationType.slideRight,
                      delayMs: 1000,
                      child: EmailField(emailController: _emailController),
                    ),
                    
                    const SizedBox(height: 30),

                    // ✅ PASSWORD FIELD
                    AnimatedField(
                      animationType: AnimationType.slideLeft,
                      delayMs: 1200,
                      child: PasswordField(
                        passwordController: _passwordController,
                        isPasswordVisible: _isPasswordVisible,
                        labelText: "Password",
                        isNewPassword: true,
                        togglePasswordVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // ✅ CONFIRM PASSWORD FIELD
                    AnimatedField(
                      animationType: AnimationType.slideRight,
                      delayMs: 1400,
                      child: PasswordField(
                        passwordController: _confirmPasswordController,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        labelText: "Confirm Password",
                        confirmPassword: _passwordController.text,
                        togglePasswordVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // ✅ BUTTONS
                    AnimatedButton(
                      delayMs: 1600,
                      animationType: ButtonAnimationType.bounce,
                      buttons: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                          child: Text(
                            "Cancel",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // ✅ USUŃ SizedBox(width: 20) - Wrap sam zadba o spacing
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            register(context);
                          },
                          child: Text(
                            "Create Account",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.white,
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
