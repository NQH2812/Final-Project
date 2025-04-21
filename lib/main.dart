import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/pages/HomePage.dart';
import 'package:movie_app/pages/LoginPage.dart';
import 'package:movie_app/service/provider.dart'; // Import provider
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase đã khởi tạo thành công');
  } catch (error) {
    print('❌ Lỗi khi khởi tạo Firebase: $error');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FavoriteMoviesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthCheck(),
    );
  }
  static of(BuildContext context) {}
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}
class _AuthCheckState extends State<AuthCheck> {
  bool _initialized = false;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null && !_initialized) {
            final provider = Provider.of<FavoriteMoviesProvider>(context, listen: false);
            provider.initializeFavorites();
            provider.loadFavoritesFromFirestore();
            _initialized = true;
          }
          return user != null ? HomePageWidget() : LoginPageWidget();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
