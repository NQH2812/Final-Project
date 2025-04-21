import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../pages/LoginPage.dart';
import '../pages/HomePage.dart'; 
import '../service/provider.dart';

class AuthService {
  // Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      return true; 
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng ký thất bại';
      if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email đã tồn tại';
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      final provider = Provider.of<FavoriteMoviesProvider>(context, listen: false);

      // 👉 Tạo document nếu chưa có
      await provider.initializeFavorites();

      // 👉 Tải danh sách phim yêu thích
      await provider.loadFavoritesFromFirestore();

      // 👉 Chuyển đến HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageWidget()),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại';
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy tài khoản người dùng';
      } else if (e.code == 'wrong-password') {
        message = 'Mật khẩu sai';
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
  }

  // Sign Out
  Future<void> signOut({
    required BuildContext context,
  }) async {
    // 👉 Clear danh sách phim yêu thích trong provider
    Provider.of<FavoriteMoviesProvider>(context, listen: false).clearFavorites();

    // 👉 Đăng xuất Firebase
    await FirebaseAuth.instance.signOut();

    // 👉 Chuyển về trang login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => LoginPageWidget()),
    );
  }
}
