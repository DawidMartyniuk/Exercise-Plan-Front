import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';

import 'package:work_plan_front/provider/training_serssion_notifer.dart';
import 'package:work_plan_front/provider/auth_provider.dart';
import 'package:work_plan_front/features/profile/widget/profile_appbar.dart';
import 'package:work_plan_front/features/profile/widget/profile_calendar_panel.dart';
import 'package:work_plan_front/features/profile/screens/profile_user_edit.dart';
import 'package:work_plan_front/features/profile/widget/profile_user_panel.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ProfilScreenState();
  }
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trainingSessionAsyncProvider.notifier).fetchSessions();
    });
  }

  String _getProfileImage() {
    final authResponse = ref.watch(authProviderLogin);
    return authResponse?.user.avatar ?? '';
  }

  String _getProfileName() {
    final authResponse = ref.watch(authProviderLogin);
    return authResponse?.user.name ?? 'User';
  }

  int _getTotalWorkouts() {
    final trainingSession = ref.watch(trainingSessionAsyncProvider);
    return trainingSession.when(
      data: (sessions) => sessions.length,
      loading: () => 0,
      error: (err, stack) => 0,
    );
  }

  String _getProfileDescription() {
    final authResponse = ref.watch(authProviderLogin);
    return authResponse?.user.description ?? 'No description available';
  }

  void loout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(authProviderLogin.notifier).logout();

      if (mounted) {
        Navigator.of(context).pop(); // Zamknij loading
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Zamknij loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout error: $e')));
      }
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
      // ✅ USUŃ PREFIX JEŚLI ISTNIEJE (data:image/jpeg;base64,)
      String cleanBase64 = imageBase64;
      if (imageBase64.contains(',')) {
        cleanBase64 = imageBase64.split(',').last;
      }

      //  DEKODUJ BASE64
      Uint8List imageBytes = base64Decode(cleanBase64);

      // ZWRÓĆ OBRAZEK Z PAMIĘCI
      return Image.memory(
        imageBytes,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // JEŚLI BŁĄD DEKODOWANIA - POKAŻ IKONĘ
          return Icon(
            Icons.person,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          );
        },
      );
    } catch (e) {
      // ✅ JEŚLI BŁĄD - POKAŻ IKONĘ
      print("❌ Błąd dekodowania base64: $e");
      return Icon(
        Icons.person,
        size: 24,
        color: Theme.of(context).colorScheme.primary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authResponse = ref.watch(authProviderLogin);
    if (authResponse == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withAlpha(127),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Please log in',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Log in to see your training calendar',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: ProfileAppBar(title: "Profile"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileUserEdit(),
                    ),
                  );
                },
                child: ProfileUserPanel(
                  buildAvatarImage: _buildAvatarImage(),
                  getProfileName: _getProfileName,
                  getProfileDescription: _getProfileDescription,
                  getTotalWorkouts: _getTotalWorkouts,
                ),
              ),
              SizedBox(height: 20),
              ProfileCalenderPanel(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                onPressed: () async {
                  // ✅ POKAZUJ LOADING
                  loout();
                },
                icon: Icon(Icons.logout),
                label: Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
