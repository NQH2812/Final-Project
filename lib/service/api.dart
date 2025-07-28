import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieService  {
  static final String _apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkOTdlZTMxOWMwYjQxYjI5MDZiMTFkZDgzNmM5MzcwZCIsIm5iZiI6MTcxNjE5Njk2MC4xNDIwMDAyLCJzdWIiOiI2NjRiMTY2MGI4N2ZkOTkwYTI4ZmE3MjMiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.JBpq1cfyAhQfiDC3ktnEKfC4rhQEH6Iu6rpmMj7mKP4";
  static String getMovieDetailUrl(int movieId) {return "https://api.themoviedb.org/3/movie/$movieId?language=en-US";}
  static String getMovieCreditsUrl(int movieId) {return "https://api.themoviedb.org/3/movie/$movieId/credits?language=en-US";}
  static String getMovieUrl(int movieId) {return "https://api.themoviedb.org/3/movie/$movieId/videos?language=en-US";} 

  static Future<dynamic> _fetchData(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Lỗi API: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi gọi API: $e');
      return null;
    }
  }

  // TRENDING MOVIES
  static Future<List<dynamic>> fetchTrendingMovies(String timeWindow) async {
    final data = await _fetchData("https://api.themoviedb.org/3/trending/movie/$timeWindow?language=en-US");
    return data?['results'] ?? [];
  }

  // POPULAR
  static Future<List<dynamic>> fetchMovies() async {
    final data = await _fetchData("https://api.themoviedb.org/3/movie/popular?language=en-US&page=1");
    return data?['results'] ?? [];
  }

  // TOP RATED
  static Future<List<dynamic>> fetchTopRatedMovies() async {
    final data = await _fetchData("https://api.themoviedb.org/3/movie/top_rated?language=en-US&page=1");
    return data?['results'] ?? [];
  }

  // GENRES
  static Future<List<dynamic>> fetchGenres() async {
    final data = await _fetchData("https://api.themoviedb.org/3/genre/movie/list?language=en");
    return data?['genres'] ?? [];
  }

  // DETAILS
  static Future<Map<String, dynamic>?> fetchMovieDetails(int movieId) async {
    return await _fetchData("https://api.themoviedb.org/3/movie/$movieId?language=en-US");
  }

  // VIDEO
  static Future<String?> fetchMovieVideo(int movieId) async {
    final data = await _fetchData("https://api.themoviedb.org/3/movie/$movieId/videos?language=en-US");
    final videos = data?["results"] as List<dynamic>? ?? [];
    if (videos.isNotEmpty) {
      return videos.first["key"]; 
    }
    return null;
  }

  // CAST
  static Future<List<dynamic>> fetchMovieCredits(int movieId) async {
    final data = await _fetchData("https://api.themoviedb.org/3/movie/$movieId/credits?language=en-US");
    return data?['cast'] ?? [];
  }

  // SEARCH
    static Future<List<dynamic>> fetchMoviesBySearch(String query) async {
    final data = await _fetchData(
        "https://api.themoviedb.org/3/search/movie?query=$query&language=en-US&page=1");
    return data?['results'] ?? [];
  }
}
