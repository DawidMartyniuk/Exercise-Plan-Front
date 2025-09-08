import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:work_plan_front/screens/auth/reset_password_page.dart';
import 'dart:async';

class DeepLinksHandle {
  static late AppLinks _appLinks;
  static StreamSubscription<Uri>? _linkSubscription;
  static bool _deepLinkHandled = false;

// Inicjalizuje obsługę deep linków
  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async{
    _appLinks = AppLinks();

    try{
      final initialUri = await _appLinks.getInitialLink();
      if(initialUri != null){
        print("🔗 Initial app link: $initialUri");
       if(_isValidResetPasswordLink(initialUri)){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleDeepLink(initialUri, navigatorKey);
          });
       }
      }
      _linkSubscription = _appLinks.uriLinkStream.listen
      ((Uri uri) {
         print("🔗 App link received: $uri");
          if(_isValidResetPasswordLink(uri)){
            _handleDeepLink(uri, navigatorKey);
          }
    });
      
      onError: (err) {
        print("❌ App link error: $err");
      }; 
      
    }catch(e){
      print("❌ Błąd inicjalizacji AppLinks: $e");
    }
  }
    static bool _isValidResetPasswordLink(Uri uri) {
    print("🔍 Checking URI: ${uri.toString()}");
    
    // Sprawdź podstawowe wymagania
    final isMyAppScheme = uri.scheme == 'myapp';
    final hasEmail = uri.queryParameters['email']?.isNotEmpty == true;
    final hasTokenInPath = uri.pathSegments.isNotEmpty;

    
    if (isMyAppScheme && hasEmail && hasTokenInPath) {
      print("✅ Valid reset password link detected!");
      return true;
    }
    
    print("❌ Not a valid reset password link");
    return false;
  }
  static void _handleDeepLink(Uri uri, GlobalKey<NavigatorState> navigatorKey){
     if (_deepLinkHandled) {
      print("🔄 Deep link już obsłużony - ignoruję duplikat");
      return;
    }
    _deepLinkHandled = true;
    try{
         final email = uri.queryParameters['email'] ?? '';
         final token = uri.pathSegments.isNotEmpty 
          ? uri.pathSegments.first 
          : uri.queryParameters['token'] ?? '';
          if(token.isNotEmpty && email.isNotEmpty && email.contains('@')){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if(navigatorKey.currentState != null){
                navigatorKey.currentState!.push(
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordPage(
                      email: email,
                      token: token
                       ),
                  ),
                );
                 Future.delayed(Duration(seconds: 1), () => _deepLinkHandled = false);
              }else{
                print("❌ Navigator nie jest jeszcze gotowy");
                 _deepLinkHandled = false;
                
              }
            });
          }
    }catch(e){
      print("❌ Błąd obsługi deep linka: $e");
      _deepLinkHandled = false;
    }

  }
    static void dispose() {
    _linkSubscription?.cancel();
  }
}
