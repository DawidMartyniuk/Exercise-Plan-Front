import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/screens/login.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';

class Startscreen extends ConsumerStatefulWidget {
  const Startscreen({super.key});

  @override
  _StartscreenState createState() => _StartscreenState();
}

class _StartscreenState extends ConsumerState<Startscreen> {
  String? userName;
  String? loginStatus;

  @override
  void initState() {
    super.initState();
    //await ExerciseService().exerciseList(forceRefresh: true);
    _checkLoginStatus();
  }

  Future<void> logout(BuildContext contex) async {
    final authNotifier = ref.read(authProviderLogin.notifier);
    await authNotifier.logout();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (ctx) => LoginScreen()));
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await getToken() != null;
    if (isLoggedIn) {
      final authResponse = ref.read(authProviderLogin);
      setState(() {
        loginStatus = authResponse?.user.name ?? "user not found"; 
      });
    } else {
      setState(() {
        loginStatus = "not logged in";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loginStatus ?? "Start Screen"),
        actions: [
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 30),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => LoginScreen()));
            },
            icon: Icon(Icons.login),
          ),
          IconButton(
            onPressed: () async {
              await logout(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to the Start Screen! $userName',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
