import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> saveMovie(Map<String, dynamic> movieData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('favorites').doc(user.uid);
    await docRef.set({
      'savedMovies': FieldValue.arrayUnion([movieData])
    }, SetOptions(merge: true));
  }

  static Future<void> removeMovie(Map<String, dynamic> movieData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('favorites').doc(user.uid);
    await docRef.update({
      'savedMovies': FieldValue.arrayRemove([movieData])
    });
  }

  static Future<List<Map<String, dynamic>>> loadSavedMovies() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final doc = await _firestore.collection('favorites').doc(user.uid).get();
    final data = doc.data();
    final movies = data?['savedMovies'] as List<dynamic>? ?? [];
    return movies.cast<Map<String, dynamic>>();
  }
}
