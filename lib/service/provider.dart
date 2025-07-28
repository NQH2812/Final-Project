import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteMoviesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favoriteMovies = [];

  List<Map<String, dynamic>> get favoriteMovies => _favoriteMovies;

  FavoriteMoviesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoriteMoviesString = prefs.getString('favorite_movies');
    if (favoriteMoviesString != null) {
      _favoriteMovies = List<Map<String, dynamic>>.from(json.decode(favoriteMoviesString));
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Map<String, dynamic> movie) async {
    final index = _favoriteMovies.indexWhere((m) => m['id'] == movie['id']);
    if (index >= 0) {
      _favoriteMovies.removeAt(index);
    } else {
      _favoriteMovies.add(movie);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorite_movies', json.encode(_favoriteMovies));

    notifyListeners();
  }

  bool isFavorite(int movieId) {
    return _favoriteMovies.any((movie) => movie['id'] == movieId);
  }

  initializeFavorites() {}
}
