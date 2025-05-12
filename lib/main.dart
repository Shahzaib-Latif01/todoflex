import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase for web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyD_BuTNxXOXKcKI_S2O16VZ6AoRysM7pew",
          authDomain: "todoflex-app-shahzaib-2b579.firebaseapp.com",
          projectId: "todoflex-app-shahzaib-2b579",
          storageBucket: "todoflex-app-shahzaib-2b579.firebasestorage.app",
          messagingSenderId: "921360040103",
          appId: "1:921360040103:web:27c2da1791e758f6b3db82",
          measurementId: "G-D494F911PR"),
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<TaskService>(
          create: (_) => TaskService(prefs),
        ),
      ],
      child: MaterialApp(
        title: 'ToDoFlex',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: StreamBuilder(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return const HomeScreen();
            }
            return const WelcomeScreen();
          },
        ),
      ),
    );
  }
}
