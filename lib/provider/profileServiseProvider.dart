import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/User.dart';
import 'package:work_plan_front/serwis/profileService.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final profileUpdateProvider = StateNotifierProvider<ProfileUpdateNotifier, AsyncValue<User?>>((ref) {
  return ProfileUpdateNotifier(ref.read(profileServiceProvider));
});

class ProfileUpdateNotifier extends StateNotifier<AsyncValue<User?>> {
  final ProfileService _profileService;

  ProfileUpdateNotifier(this._profileService) : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    required int userId,
    required String name,
    required String email,
    File? avatarFile,
    String? description,
    int? weight,
  }) async {
    state = const AsyncValue.loading();

   
    try {
      String? avatarBase64;

       if (avatarFile != null) {
        avatarBase64 = await _profileService.fileToBase64(avatarFile);
      }

    
      final updatedUser = await _profileService.updateProfile(
        userId: userId,
        name: name,
        email: email,
        description: description, 
        weight: weight?.toString(),
        avatar: avatarBase64, 
        
      );
      
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateAvatar(String base64Image) async {
    state = const AsyncValue.loading();
    
    try {
      final updatedUser = await _profileService.updateAvatar(base64Image);
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}