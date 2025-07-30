import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_plan_front/provider/TrainingSerssionNotifer.dart';
import 'package:work_plan_front/provider/authProvider.dart';

class ProfileUserEdit extends ConsumerStatefulWidget {
  const ProfileUserEdit({super.key});
  @override
  _ProfileUserEditState createState() => _ProfileUserEditState();
}

class _ProfileUserEditState extends ConsumerState<ProfileUserEdit> {
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
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
        _bioController.text = 'Enter your bio here';
        _weightController.text = '70'; 
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
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
    Future<void> _pickImage(ImageSource source ) async {
    try{
      final XFile? image = await _picker.pickImage(
        source: source,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 80,
        );

        if(image != null){
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

  Widget _buildAvatarImage() {
    final imageBase64 = _getProfileImage();

    if (imageBase64.isEmpty) {
      return Icon(
        Icons.person,
        size: 50,
        color: Theme.of(context).colorScheme.primary,
      );
    }

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
      return Icon(
        Icons.person,
        size: 50,
        color: Theme.of(context).colorScheme.primary,
      );
    }
  }

  // ✅ POPRAWIONA METODA - BEZ ROW
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
         
         Text('Edit Profile',
         textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            
          ),
         ),
         
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column( // ✅ ZMIENIONO Z SINGLECHILDSCROLLVIEW
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
                child: 
                _buildAvatarImage(),
              ),
            ),
            
            SizedBox(height: 20),
            
            // ✅ FORM FIELDS - USUŃ EXPANDED
            Expanded( // ✅ EXPANDED TYLKO TUTAJ
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    textEditConstructor('Name', _nameController),
                    textEditConstructor('Email', _emailController), 
                    textEditConstructor('Bio', _bioController),
                    textEditConstructor('Weight', _weightController),
                    
                    SizedBox(height: 30),
                    
                    // ✅ SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          print('Name: ${_nameController.text}');
                          print('Email: ${_emailController.text}');
                          print('Bio: ${_bioController.text}');
                          print('Weight: ${_weightController.text}');
                          
                          // ✅ POWRÓT DO PROFILU
                          Navigator.pop(context);
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
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
