import 'package:expence_tracker_app/firebase_options.dart';
import 'package:expence_tracker_app/home_screen.dart';
import 'package:expence_tracker_app/login_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const _AuthgState(),
    );
  }
}

class _AuthgState extends StatefulWidget {
  const _AuthgState({super.key});

  @override
  State<_AuthgState> createState() => __AuthgStateState();
}

class __AuthgStateState extends State<_AuthgState> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LoginUi();
        }
      },
    );
  }
}
