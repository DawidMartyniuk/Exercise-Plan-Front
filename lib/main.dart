import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';
import 'package:work_plan_front/screens/auth/login.dart';
import 'package:work_plan_front/screens/auth/reset_password_page.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:work_plan_front/serwis/exerciseService.dart';
import 'package:work_plan_front/theme/app_theme.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ INICJALIZACJA HIVE
  await Hive.initFlutter();
  Hive.registerAdapter(ExerciseAdapter());

  // ✅ PRELOAD ĆWICZEŃ
  try {
    final exerciseService = ExerciseService();
    final exercises = await exerciseService.exerciseList(forceRefresh: true);
    print("🚀 Załadowano ${exercises?.length ?? 0} ćwiczeń przy starcie");
  } catch (e) {
    print("❌ Błąd ładowania ćwiczeń przy starcie: $e");
  }

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _deepLinkHandled = false;

  @override
  void initState() {
    super.initState();
    initAppLinks();
  }

  void initAppLinks() async {
    _appLinks = AppLinks();

    try {
      // ✅ SPRAWDŹ INITIAL LINK TYLKO JEŚLI ISTNIEJE I JEST PRAWIDŁOWY
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print("🔗 Initial app link: $initialUri");

        // ✅ SPRAWDŹ CZY TO RZECZYWIŚCIE LINK DO RESETU HASŁA
        if (_isValidResetPasswordLink(initialUri)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            handleDeepLink(initialUri);
          });
        } else {
          print("🔍 Initial link nie jest linkiem do resetu hasła - ignoruję");
        }
      } else {
        print("🔍 Brak initial link - normalny start aplikacji");
      }

      // ✅ SŁUCHAJ NOWYCH LINKÓW
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          print("🔗 App link received: $uri");
          if (_isValidResetPasswordLink(uri)) {
            handleDeepLink(uri);
          } else {
            print("🔍 Otrzymany link nie jest linkiem do resetu hasła - ignoruję");
          }
        },
        onError: (err) {
          print("❌ App link error: $err");
        },
      );
    } catch (e) {
      print("❌ Błąd inicjalizacji app_links: $e");
    }
  }

  // ✅ SPRAWDŹ CZY LINK JEST DO RESETU HASŁA
  bool _isValidResetPasswordLink(Uri uri) {
    print("🔍 Checking URI: ${uri.toString()}");
    
    // Sprawdź podstawowe wymagania
    final isMyAppScheme = uri.scheme == 'myapp';
    final hasEmail = uri.queryParameters['email']?.isNotEmpty == true;
    final hasTokenInPath = uri.pathSegments.isNotEmpty;

    print("🔍 Simple validation:");
    print("  - Is myapp scheme: $isMyAppScheme");
    print("  - Has email param: $hasEmail");
    print("  - Has path segments: $hasTokenInPath");
    
    if (isMyAppScheme && hasEmail && hasTokenInPath) {
      print("✅ Valid reset password link detected!");
      return true;
    }
    
    print("❌ Not a valid reset password link");
    return false;
  }

  void handleDeepLink(Uri uri) {
    if (_deepLinkHandled) {
      print("🔄 Deep link już obsłużony - ignoruję duplikat");
      return;
    }

    _deepLinkHandled = true;
    
    try {
      final email = uri.queryParameters['email'] ?? '';
      String token = '';
      
      if (uri.pathSegments.isNotEmpty) {
        token = uri.pathSegments.first;
      } else {
        token = uri.queryParameters['token'] ?? '';
      }

      print("🔍 Extracted token: '$token'");
      print("🔍 Extracted email: '$email'");

      // ✅ WALIDACJA DANYCH
      if (token.isNotEmpty && email.isNotEmpty && email.contains('@')) {
        // ✅ POCZEKAJ AŻ NAVIGATOR BĘDZIE GOTOWY
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (_) => ResetPasswordPage(email: email, token: token),
              ),
            );
            print("🔐 Otwieram ResetPasswordPage z tokenem i emailem");
          } else {
            print("❌ Navigator nie jest jeszcze gotowy");
          }

          // ✅ RESET FLAGI PO KRÓTKIM CZASIE
          Future.delayed(Duration(seconds: 1), () {
            _deepLinkHandled = false;
          });
        });
      } else {
        print("❌ Nieprawidłowe dane. Token: '$token', Email: '$email'");
        _deepLinkHandled = false;
      }
    } catch (e) {
      print("❌ Błąd podczas przetwarzania deep link: $e");
      _deepLinkHandled = false;
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ OBSERWUJ STAN AUTORYZACJI
    final authState = ref.watch(authProviderLogin);
    
    return MaterialApp(
      title: 'Exercise Plan App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      navigatorKey: navigatorKey,
      // ✅ ZAWSZE ZACZNIJ OD LOGIN SCREEN
      home:
      LoginScreen(),
      routes: {
        '/tabs': (_) => TabsScreen(selectedPageIndex: 0),
        '/login': (_) => LoginScreen(),
      },
    );
  }
}
