import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/service/provider.dart';
import 'package:movie_app/pages/MovieDetails.dart'; 

class FavoriteMoviesScreen extends StatelessWidget {
  const FavoriteMoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteMoviesProvider>(context);
    final favoriteMovies = favoriteProvider.favoriteMovies;

    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites movies", 
                  style: TextStyle(color: Colors.white),
                ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color.fromARGB(255, 202, 30, 39),
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: favoriteMovies.isEmpty
          ? Center(
              child: Text(
                "No favorite movies yet",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = favoriteMovies[index];
                final poster = movie['poster_path'];
                final title = movie['title'] ?? 'No Title';
                final rating = (movie['vote_average'] ?? 0).toDouble();
                final language = movie['original_language']?.toUpperCase() ?? 'N/A';
                final movieId = movie['id'];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsWidget(movieId: movieId),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                          child: Image.network(
                            poster != null
                                ? 'https://image.tmdb.org/t/p/w200$poster'
                                : 'https://via.placeholder.com/100x150.png?text=No+Image',
                            height: 150,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Language: $language',
                                  style: TextStyle(fontSize: 13, color: Colors.black54),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.star, size: 16, color: Color(0xFFFFD300)),
                                    SizedBox(width: 4),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: Icon(Icons.bookmark_remove, color: Colors.red),
                                    onPressed: () => favoriteProvider.toggleFavorite(movie),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
