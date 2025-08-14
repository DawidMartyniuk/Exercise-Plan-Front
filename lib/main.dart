import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/auth/reset_password_page.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:work_plan_front/theme/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:work_plan_front/serwis/exerciseService.dart';
// ✅ ZMIEŃ IMPORT
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ INICJALIZACJA HIVE
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  // ✅ REJESTRACJA ADAPTERA
  Hive.registerAdapter(ExerciseAdapter());
  
  // ✅ OTWÓRZ BOX NAJPIERW
  await Hive.openBox<Exercise>('exerciseBox');

  // ✅ POTEM ZAŁADUJ ĆWICZENIA
  try {
    final exerciseService = ExerciseService();
    final exercises = await exerciseService.exerciseList();
    print("🚀 Załadowano ${exercises?.length ?? 0} ćwiczeń przy starcie");
  } catch (e) {
    print("❌ Błąd ładowania ćwiczeń przy starcie: $e");
  }

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // ✅ ZMIEŃ NA APP_LINKS
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // ✅ INICJALIZUJ APP_LINKS
    initAppLinks();
  }

  // ✅ NOWA METODA DLA APP_LINKS
  void initAppLinks() async {
    _appLinks = AppLinks();

    try {
      // Sprawdź czy aplikacja została uruchomiona z linku
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print("🔗 Initial app link: $initialUri");
        handleDeepLink(initialUri);
      }

      // Nasłuchuj nowych linków
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          print("🔗 App link received: $uri");
          handleDeepLink(uri);
        },
        onError: (err) {
          print("❌ App link error: $err");
        },
      );
    } catch (e) {
      print("❌ Błąd inicjalizacji app_links: $e");
    }
  }

  // ✅ OBSŁUGA DEEP LINKS - DOPASOWANA DO BACKENDU
  void handleDeepLink(Uri uri) {
    print("🔍 Handling deep link: ${uri.toString()}");
    print("🔍 Path segments: ${uri.pathSegments}");
    print("🔍 Query parameters: ${uri.queryParameters}");

    // ✅ OBSŁUGA RESET HASŁA - NOWY FORMAT /open-reset/{token}
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'open-reset') {
      final token = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
      final email = uri.queryParameters['email'] ?? '';

      print("🔐 Reset password link - Email: $email, Token: ${token.isNotEmpty ? 'Present' : 'Missing'}");
      print("🔐 Full token: $token");

      // ✅ SPRAWDŹ CZY MAMY WYMAGANE DANE
      if (token.isNotEmpty && email.isNotEmpty) {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ResetPasswordPage(
                email: email,
                token: token,
              ),
            ),
            (route) => false, // Usuń wszystkie poprzednie ekrany
          );
        }
      } else {
        print("❌ Niepełne dane resetu hasła - Token: ${token.isNotEmpty}, Email: ${email.isNotEmpty}");
      }
    }
    // ✅ OBSŁUGA WERYFIKACJI EMAIL (OPCJONALNIE)
    else if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'verify-email') {
      final token = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
      final email = uri.queryParameters['email'] ?? '';
      
      print("📧 Email verification link - Email: $email, Token: ${token.isNotEmpty ? 'Present' : 'Missing'}");
      
      // ✅ TUTAJ MOŻESZ DODAĆ OBSŁUGĘ WERYFIKACJI EMAIL
      // if (navigatorKey.currentState != null) {
      //   navigatorKey.currentState!.pushAndRemoveUntil(
      //     MaterialPageRoute(
      //       builder: (context) => EmailVerificationPage(
      //         email: email,
      //         token: token,
      //       ),
      //     ),
      //     (route) => false,
      //   );
      // }
    }
    // ✅ OBSŁUGA STARYCH FORMATÓW (BACKWARD COMPATIBILITY)
    else if (uri.path == '/reset-password') {
      final token = uri.queryParameters['token'] ?? '';
      final email = uri.queryParameters['email'] ?? '';
      
      print("🔐 Legacy reset password link - Email: $email, Token: ${token.isNotEmpty ? 'Present' : 'Missing'}");
      
      if (token.isNotEmpty && email.isNotEmpty) {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ResetPasswordPage(
                email: email,
                token: token,
              ),
            ),
            (route) => false,
          );
        }
      }
    }
    // ✅ NIEZNANE LINKI
    else {
      print("⚠️ Nieznany deep link: ${uri.path}");
      print("⚠️ Path segments: ${uri.pathSegments}");
    }
  }

  @override
  void dispose() {
    // ✅ ANULUJ SUBSKRYPCJĘ
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise Plan App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      navigatorKey: navigatorKey, // ✅ WAŻNE: Navigator key do deep links
      home: TabsScreen(
        selectedPageIndex: 0,
      ),
      // ✅ ZAKTUALIZOWANE ROUTES
      routes: {
        '/reset-password': (context) => ResetPasswordPage(
          email: '',
          token: '',
        ),
        '/open-reset': (context) => ResetPasswordPage(
          email: '',
          token: '',
        ),
      },
    );
  }
}


