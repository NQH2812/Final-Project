import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_app/pages/LoginPage.dart';
import 'package:movie_app/pages/HomePage.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAaiQazsz3jwU47boDS4Q-Y8UV2DHGMmXE",
        authDomain: "authuser-ba081.firebaseapp.com",
        projectId: "authuser-ba081",
        storageBucket: "authuser-ba081.appspot.com",
        messagingSenderId: "1004901029590",
        appId: "1:1004901029590:android:0e6a1f1ea4178e33f39b77",
      ),
    );
      print('✅ Firebase đã khởi tạo thành công');
    } catch(error) {
      print('❌ Lỗi khi khởi tạo Firebase: $error');
    };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPageWidget(),
            // const HomePageWidget()
    );
  }
  static of(BuildContext context) {}
}
