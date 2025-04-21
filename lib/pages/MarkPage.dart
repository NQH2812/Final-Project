import 'package:flutter/material.dart';
import 'package:movie_app/flutter_flow/flutter_flow_model.dart';
import 'package:movie_app/flutter_flow/flutter_flow_theme.dart';
import 'package:movie_app/flutter_flow/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import '../service/provider.dart';
import '../model/MarkPageModel.dart';

class MarkPageWidget extends StatefulWidget {
  const MarkPageWidget({super.key});

  static String routeName = 'MarkPage';
  static String routePath = '/markPage';

  @override
  State<MarkPageWidget> createState() => _MarkPageWidgetState();
}

class _MarkPageWidgetState extends State<MarkPageWidget> {
  late MarkPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MarkPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteMoviesProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFFC30303),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Mark',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 22,
                ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: favoriteProvider.favoriteMovies.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_rounded, color: Color(0xFFC30303), size: 64),
                      SizedBox(height: 10),
                      Text(
                        'Bookmark List is empty',
                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                              fontFamily: 'Inter Tight',
                              fontSize: 22,
                            ),
                      ),
                      Text(
                        'After bookmarking movies and series, they are displayed here',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: favoriteProvider.favoriteMovies.length,
                    itemBuilder: (context, index) {
                      final movie = favoriteProvider.favoriteMovies[index];

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
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                                width: 80,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie['title'],
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text("Language: ${movie['original_language']}"),
                                  const SizedBox(height: 5),
                                  Text("⭐ ${(movie['vote_average'] ?? 0).toStringAsFixed(1)}"),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => favoriteProvider.toggleFavorite(movie),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

