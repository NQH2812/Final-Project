import 'dart:async';
import 'package:flutter/material.dart';
import '../service/api.dart';
import '../component/BottomNav.dart';
import '../pages/MovieDetails.dart';

class SearchPageWidget extends StatefulWidget {
  const SearchPageWidget({super.key});

  static String routeName = 'SearchPage';
  static String routePath = '/searchPage';

  @override
  State<SearchPageWidget> createState() => _SearchPageWidgetState();
}

class _SearchPageWidgetState extends State<SearchPageWidget> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        setState(() => _isLoading = true);
        final results = await MovieService.fetchMoviesBySearch(query);
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      } else {
        setState(() => _searchResults = []);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    final searchBarColor = isDarkMode ? Colors.grey[900] : Colors.grey[200];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  prefixIcon: Icon(Icons.search, color: Colors.red),
                  filled: true,
                  fillColor: searchBarColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: textColor),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.red))
                  : _searchResults.isEmpty
                      ? Center(child: Text("No results found", style: TextStyle(color: secondaryTextColor)))
                      : ListView.builder(
                          key: PageStorageKey<String>('searchResultsKey'),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final movie = _searchResults[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 10, 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                                  ],
                                ),
                              child: ListTile(
                                leading: movie["poster_path"] != null
                                    ? Image.network(
                                        "https://image.tmdb.org/t/p/w200${movie["poster_path"]}",
                                        width: 80,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(Icons.movie, color: secondaryTextColor, size: 50),
                                title: Text(
                                  movie["title"] ?? "Unknown Title",
                                  maxLines: 1,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Color(0xFFFFD300),
                                      size: 16,
                                    ),
                                    Text(
                                      "${(movie["vote_average"] ?? 0).toDouble().toStringAsFixed(1)}",
                                      style: TextStyle(color: textColor),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => DetailsWidget(movieId: movie["id"])));
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: 1),
      ),
    );
  }
}
