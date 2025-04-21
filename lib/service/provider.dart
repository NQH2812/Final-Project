import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteMoviesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favoriteMovies = [];
  List<Map<String, dynamic>> get favoriteMovies => _favoriteMovies;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Kiểm tra phim đã được lưu chưa
  bool isFavorite(int movieId) {
    return _favoriteMovies.any((movie) => movie['id'] == movieId);
  }

  /// Đơn giản hoá dữ liệu phim để phù hợp với Firestore
  Map<String, dynamic> _simplifyMovie(Map<String, dynamic> movie) {
    return {
      'id': movie['id'],
      'title': movie['title'],
      'poster_path': movie['poster_path'],
    };
  }

  /// Tạo document nếu chưa có khi user đăng nhập lần đầu
  Future<void> initializeFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('favorites').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      print('[Firestore] Creating new document for user: ${user.uid}');
      await docRef.set({'savedMovies': []});
    } else {
      print('[Firestore] Document already exists for user: ${user.uid}');
    }
  }

  /// Tải danh sách phim yêu thích từ Firestore sau khi đăng nhập
  Future<void> loadFavoritesFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('favorites').doc(user.uid).get();
    final data = doc.data();
    final movies = data?['savedMovies'] as List<dynamic>? ?? [];

    _favoriteMovies = movies.map((m) => Map<String, dynamic>.from(m)).toList();
    print('[Firestore] Loaded ${_favoriteMovies.length} favorite movies');
    notifyListeners();
  }

  /// Xoá toàn bộ danh sách khi đăng xuất
  void clearFavorites() {
    _favoriteMovies.clear();
    print('[Favorites] Cleared on sign out');
    notifyListeners();
  }

  /// Thêm hoặc xoá phim yêu thích và cập nhật Firestore
  Future<void> toggleFavorite(Map<String, dynamic> movie) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('favorites').doc(user.uid);
    final simplified = _simplifyMovie(movie);

    if (isFavorite(movie['id'])) {
      _favoriteMovies.removeWhere((m) => m['id'] == movie['id']);
      await docRef.set({
        'savedMovies': FieldValue.arrayRemove([simplified])
      }, SetOptions(merge: true));
      print('[Favorites] Removed movie ${movie['id']}');
    } else {
      _favoriteMovies.add(simplified);
      await docRef.set({
        'savedMovies': FieldValue.arrayUnion([simplified])
      }, SetOptions(merge: true));
      print('[Favorites] Added movie ${movie['id']}');
    }

    notifyListeners();
  }
}
