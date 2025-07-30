import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/provider/TrainingSerssionNotifer.dart';
import 'package:work_plan_front/provider/authProvider.dart';

class ProfilScreen extends ConsumerStatefulWidget {
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
      ref.read(completedTrainingSessionProvider.notifier).fetchSessions();
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
    final trainingSession = ref.watch(completedTrainingSessionProvider);
    return trainingSession.length;
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

      // ✅ DEKODUJ BASE64
      Uint8List imageBytes = base64Decode(cleanBase64);

      // ✅ ZWRÓĆ OBRAZEK Z PAMIĘCI
      return Image.memory(
        imageBytes,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // ✅ JEŚLI BŁĄD DEKODOWANIA - POKAŻ IKONĘ
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
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100, // ✅ ZWIĘKSZ SZEROKOŚĆ DLA WIĘKSZEGO PRZYCISKU
        leading: Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6), // ✅ ZMNIEJSZ MARGINES
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary, // ✅ ZMIEŃ NA PRIMARY
            borderRadius: BorderRadius.circular(20), // ✅ ZWIĘKSZ PROMIEŃ
           
          
            
          ),
          child: TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // ✅ DODAJ PADDING
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: Icon(
              Icons.edit, // ✅ IKONA EDYCJI
              size: 16, 
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: Text(
              'Edit',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6), 
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(20), 
             
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.secondary.withAlpha(100),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onSecondary,
                size: 22, // ✅ ZWIĘKSZ ROZMIAR IKONY
              ),
              onPressed: () {},
              style: IconButton.styleFrom(
                padding: EdgeInsets.all(12), // ✅ ZWIĘKSZ PADDING
                minimumSize: Size(48, 48), // ✅ ZWIĘKSZ MINIMALNY ROZMIAR
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
        title: Center(child: Text('Profile')),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ AVATAR
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSecondary,
                        width: 2,
                      ),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(50),
                    ),
                    child: ClipOval(child: _buildAvatarImage()),
                  ),

                  SizedBox(width: 16), // ✅ ODSTĘP MIĘDZY AVATAREM A TEKSTEM
                  // ✅ TEKST
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getProfileName(),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 8), // tutaj będzie mały opis takie Bio
                        Text(
                          'Welcome to your profile!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Workouts",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(180),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _getTotalWorkouts().toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(child: Text('Here will be your profile details')),
          ],
        ),
      ),
    );
  }
}
