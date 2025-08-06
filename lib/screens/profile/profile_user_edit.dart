import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_plan_front/model/authResponse.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/provider/profileServiseProvider.dart';
import 'package:work_plan_front/utils/toast_untils.dart';



class ProfileUserEdit extends ConsumerStatefulWidget {
  const ProfileUserEdit({super.key});
  @override
  _ProfileUserEditState createState() => _ProfileUserEditState();
}

class _ProfileUserEditState extends ConsumerState<ProfileUserEdit> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authResponse = ref.read(authProviderLogin);
      if (authResponse != null) {
        _nameController.text = authResponse.user.name ?? '';
        _emailController.text = authResponse.user.email ?? '';
        _descriptionController.text = authResponse.user.description ?? '';
             _weightController.text = authResponse.user.weight?.toString() ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String _getProfileImage() {
    final authResponse = ref.watch(authProviderLogin);
    return authResponse?.user.avatar ?? '';
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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

      // ✅ TOAST SUKCESU DLA WYBORU OBRAZU
      ToastUtils.showSuccessToast(
        context: context,
        title: "Image Selected",
        message: "Profile image has been selected successfully.",
      );
    } catch (e) {
      print("Błąd podczas wybierania obrazu: $e");
      ToastUtils.showErrorToast(
        context: context,
        title: "Image Selection Failed",
        message: "Failed to select image. Please try again.",
      );
    }
  }

  Widget _buildAvatarImage() {
    //  nAJPIERW SPRAWDŹ CZY JEST LOKALNY OBRAZ

     final authResponse = ref.watch(authProviderLogin);
    if (_profileImage != null) {
      return ClipOval(
        child: Image.file(
          _profileImage!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    //  POTEM SPRAWDŹ BASE64 Z SERWERA
    final imageBase64 = _getProfileImage();
    print("🔍 Avatar w profilu: '${imageBase64.substring(0, imageBase64.length > 50 ? 50 : imageBase64.length)}...'"); // ✅ DEBUG
    if (imageBase64.isNotEmpty) {
      try {
        String cleanBase64 = imageBase64;
        if (imageBase64.contains(',')) {
          cleanBase64 = imageBase64.split(',').last;
        }

        Uint8List imageBytes = base64Decode(cleanBase64);

        return ClipOval(
          child: Image.memory(
            imageBytes,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              );
            },
          ),
        );
      } catch (e) {
        print("❌ Błąd dekodowania base64: $e");
      }
    }

    // DOMYŚLNA IKONA
    return Icon(
      Icons.person,
      size: 50,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Future<void> updateProfile(
    String name,
    String email,
    String description,
    int weight,
  ) async {
    final authResponse = ref.read(authProviderLogin);
    if (authResponse != null) {
    final currentUser = authResponse.user;
     //zmiana 
    
     final changes = <String, dynamic>{};
    
    if (name != currentUser.name) {
      changes['name'] = name;
      print("🔄 Zmiana name: '${currentUser.name}' → '$name'");
    }
    if (email != currentUser.email) {
      changes['email'] = email;
      print("🔄 Zmiana email: '${currentUser.email}' → '$email'");
    }
    if (description != (currentUser.description ?? '')) {
      changes['description'] = description;
      print("🔄 Zmiana description: '${currentUser.description ?? ''}' → '$description'");
    }
    if (weight != (currentUser.weight?.toString() ?? '')) {
      changes['weight'] = weight;
      print("🔄 Zmiana weight: '${currentUser.weight?.toString() ?? ''}' → '$weight'");
    }
    if (_profileImage != null) {
      changes['avatar'] = 'NEW_IMAGE';
      print("🔄 Zmiana avatar: nowy obraz wybrany");
    }
    
    if (changes.isEmpty) {
      ToastUtils.showValidationError(
        context,
        customMessage: "No changes detected. Please modify at least one field.",
      );
      return;
    }
    
    print("📋 Detected changes: ${changes.keys.join(', ')}");
    }
    

     //zmaian 

      final changes = <String, dynamic>{};
    if (authResponse != null) {
      if (name.trim().isEmpty) {
        ToastUtils.showValidationError(
          context,
          customMessage: "Name field cannot be empty.",
        );
        return; // ✅ POZOSTAŃ NA STRONIE
      }

      if (email.trim().isEmpty || !email.contains('@')) {
        ToastUtils.showValidationError(
          context,
          customMessage: "Please enter a valid email address.",
        );
        return; // ✅ POZOSTAŃ NA STRONIE
      }

      try {
        // ✅ POKAŻ LOADING TOAST
        ToastUtils.showSuccessToast(
          context: context,
          title: "Updating...",
          message: "Please wait while we update your profile.",
          duration: Duration(seconds: 2),
        );

        await ref
            .read(profileUpdateProvider.notifier)
            .updateProfile(
              userId: authResponse.user.id,
              name: name,
              email: email,
              avatarFile: _profileImage,
              description: description, 
              weight: weight,
            );

        final updateState = ref.read(profileUpdateProvider);

        updateState.when(
          data: (user) {
            if (user != null) {
              final currentAuth = ref.read(authProviderLogin);
              if (currentAuth != null) {
                // ✅ STWÓRZ NOWY OBIEKT BEZPOŚREDNIO
                final updatedAuthResponse = AuthResponse(
                  message: currentAuth.message,
                  token: currentAuth.token,
                  user: user, // ✅ BEZPOŚREDNIE PRZYPISANIE
                );
                ref.read(authProviderLogin.notifier).state = updatedAuthResponse;
                print("✅ Zaktualizowano dane użytkownika w authProvider");
              }
              
              // ✅ SUKCES - WYŚWIETL TOAST I WYJDŹ
              ToastUtils.showSaveSuccess(context, itemName: "Profile");
              Navigator.pop(context);
            } else {
              // ❌ BŁĄD - POZOSTAŃ NA STRONIE
              ToastUtils.showErrorToast(
                context: context,
                title: "Update Failed",
                message: "Failed to update profile. Please try again.",
              );
            }
          },
          error: (error, stack) {
            // ❌ BŁĄD - POZOSTAŃ NA STRONIE
            print("❌ Provider Error: $error");
            
            String errorMessage = "Failed to update profile. Please try again.";
            
            // ✅ OBSŁUŻ KONKRETNE BŁĘDY
            if (error.toString().contains('email has already been taken')) {
              errorMessage = "This email is already in use. Please use a different email address.";
            } else if (error.toString().contains('connection') || 
                       error.toString().contains('network') || 
                       error.toString().contains('timeout')) {
              errorMessage = "Network connection failed. Please check your internet and try again.";
            } else if (error.toString().contains('401') || 
                       error.toString().contains('unauthorized')) {
              errorMessage = "Session expired. Please login again.";
            } else if (error.toString().contains('422')) {
              errorMessage = "Invalid data provided. Please check your input and try again.";
            }
            
            ToastUtils.showErrorToast(
              context: context,
              title: "Update Error",
              message: errorMessage,
              duration: Duration(seconds: 5),
            );
            // ❌ NIE WYWOŁUJ Navigator.pop()
          },
          loading: () {
            // Loading już pokazany wcześniej
          },
        );
      } catch (e) {
        // ❌ BŁĄD - POZOSTAŃ NA STRONIE
        print("❌ Błąd aktualizacji profilu: $e");

        String errorMessage = "An unexpected error occurred. Please try again.";
        
        // ✅ OBSŁUŻ KONKRETNE BŁĘDY
        if (e.toString().contains('email has already been taken')) {
          errorMessage = "This email is already in use. Please use a different email address.";
        } else if (e.toString().contains('connection') ||
            e.toString().contains('network') ||
            e.toString().contains('timeout')) {
          errorMessage = "Network connection failed. Please check your internet and try again.";
        }

        ToastUtils.showErrorToast(
          context: context,
          title: "Update Error", 
          message: errorMessage,
          duration: Duration(seconds: 5),
        );
        // ❌ NIE WYWOŁUJ Navigator.pop()
      }
    } else {
      // ❌ BŁĄD AUTORYZACJI - POZOSTAŃ NA STRONIE
      ToastUtils.showErrorToast(
        context: context,
        title: "Authentication Error",
        message: "You are not logged in. Please login again.",
      );
      // ❌ NIE WYWOŁUJ Navigator.pop()
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),

        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ AVATAR SECTION
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                  color: Theme.of(context).colorScheme.primary.withAlpha(50),
                ),
                child: _buildAvatarImage(),
              ),
            ),

            SizedBox(height: 20),

            // ✅ FORM FIELDS - USUŃ EXPANDED
            Expanded(
              // ✅ EXPANDED TYLKO TUTAJ
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    textEditConstructor('Name', _nameController),
                    textEditConstructor('Email', _emailController),
                    textEditConstructor('Bio', _descriptionController),
                    textEditConstructor('Weight', _weightController),

                    SizedBox(height: 30),

                    // ✅ SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          updateProfile(
                            _nameController.text,
                            _emailController.text,
                            _descriptionController.text,
                          int.tryParse(_weightController.text) ?? 0, 
                          );
                          
                          print('Name: ${_nameController.text}');
                          print('Email: ${_emailController.text}');
                          print('Bio: ${_descriptionController.text}');
                          print('Weight: ${_weightController.text}');

                          // ❌ USUŃ TO - Navigator.pop() będzie tylko przy sukcesie
                          // Navigator.pop(context);
                        },
                        child: Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textEditConstructor(String title, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter your $title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              // Handle change
            },
          ),
        ],
      ),
    );
  }
}
