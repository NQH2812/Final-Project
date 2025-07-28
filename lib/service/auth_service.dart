import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../pages/LoginPage.dart';
import '../pages/HomePage.dart'; 

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
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => HomePageWidget())
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
  // Đăng xuất Firebase
  await FirebaseAuth.instance.signOut();

  // Chuyển về trang login
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) => LoginPageWidget()),
  );
 }

 // change password
  Future<bool> changePassword({
  required String currentPassword,
  required String newPassword,
  required BuildContext context,
}) async {
  try {
    // Lấy user hiện tại
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      Fluttertoast.showToast(
        msg: "No user is currently logged in",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
    
    // Xác thực lại người dùng với mật khẩu hiện tại
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    
    // Đăng nhập lại để xác thực
    await user.reauthenticateWithCredential(credential);
    
    // Tiến hành đổi mật khẩu
    await user.updatePassword(newPassword);
    
    Fluttertoast.showToast(
      msg: "Password changed successfully",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
    
    return true;
  } on FirebaseAuthException catch (e) {
    String message = 'Password change failed';
    
    if (e.code == 'wrong-password') {
      message = 'Current password is incorrect';
    } else if (e.code == 'weak-password') {
      message = 'New password is too weak';
    } else if (e.code == 'requires-recent-login') {
      message = 'Please log in again to perform this action';
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
  } catch (e) {
    Fluttertoast.showToast(
      msg: "An error occurred: ${e.toString()}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 14.0,
    );
    return false;
  }
}
}