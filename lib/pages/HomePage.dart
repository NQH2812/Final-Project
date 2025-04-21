import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:movie_app/pages/MovieDetails.dart';
import 'package:movie_app/service/api.dart';
import 'package:movie_app/component/MovieCard.dart';
import '../component/BottomNav.dart';
import '../pages/ListMovie.dart';
import 'package:movie_app/model/HomePageModel.dart';
export 'package:movie_app/model/HomePageModel.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
 // Tạo danh sách phim
  List<dynamic> popularMovies = [];
  List<dynamic> topRatedMovies = [];
  Map<int, String> genreMap = {};
  List<dynamic> trendingMovies = [];

  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    fetchMovies();
    fetchTopRatedMovies(); 
    fetchGenres();
    fetchTrendingMovies();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

 // GET API
 Future<void> fetchMovies() async {
    final fetchedMovies = await MovieService.fetchMovies();
    if (mounted) {
      setState(() {
        popularMovies = fetchedMovies;
        isLoading = false;
      });
    }
 }

 // GET API TOP RATED
 Future<void> fetchTopRatedMovies() async {
    final fetchedMovies = await MovieService.fetchTopRatedMovies();
    if (mounted) {
      setState(() {
        topRatedMovies = fetchedMovies;
        isLoading = false;
      });
    }
  }

 // GET GENRE ID 
 Future<void> fetchGenres() async {
    final genres = await MovieService.fetchGenres(); 
    if (mounted) {
      setState(() {
        genreMap = {for (var genre in genres) genre['id']: genre['name']};
      });
    }
  }

  //GET TRENDING MOVIES
  Future<void> fetchTrendingMovies() async {
  final fetchedTrendingMovies = await MovieService.fetchTrendingMovies('week'); 
  if (mounted) {
    setState(() {
      trendingMovies = fetchedTrendingMovies;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  height: 400,
                  child: GestureDetector(
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 40),
                          child: isLoading
                              ? Center(child: CircularProgressIndicator())
                              : PageView.builder(
                            controller: _model.pageViewController ??= PageController(viewportFraction: 0.9),
                            onPageChanged: (index) {
                              _model.resetAutoScrollTimer(); 
                            },
                            scrollDirection: Axis.horizontal,
                            itemCount: trendingMovies.length >= 5 ? 5 : trendingMovies.length,
                            itemBuilder: (context, index) {
                              final moviePageview = trendingMovies [index];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w500${moviePageview['backdrop_path']}',
                                      width: double.infinity,
                                      height: 400,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0, 1),
                                    child: Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            FlutterFlowTheme.of(context)
                                                .primaryBackground
                                          ],
                                          stops: [0, 1],
                                          begin: AlignmentDirectional(0, -1),
                                          end: AlignmentDirectional(0, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0, 0.85),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24, 0, 24, 0),
                                      child: Container(
                                        width: double.infinity,
                                        height: 70,
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                                                    child: SizedBox(
                                                      width: 400,
                                                      child: Text(
                                                        trendingMovies[index]['title'],
                                                        maxLines: 1,
                                                        overflow: TextOverflow.fade, 
                                                        softWrap: false,
                                                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 25,
                                                          letterSpacing: 0.0,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    trendingMovies[index]['genre_ids']
                                                        .map((id) => genreMap[id] ?? 'Unknown')
                                                        .join(' • '),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style:
                                                        FlutterFlowTheme.of(context).bodyMedium.override(
                                                              fontFamily: 'Poppins',
                                                              fontSize: 12,
                                                              letterSpacing: 0.0,
                                                              fontWeight:  FontWeight.w500,
                                                            ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.play_circle_fill_outlined, 
                                                  size: 40,
                                                  color: Color.fromARGB(255, 202, 30, 39),
                                                ),
                                                onPressed: () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => DetailsWidget(movieId: trendingMovies[index]['id'],))
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0, 1),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                            child: smooth_page_indicator.SmoothPageIndicator(
                              controller: _model.pageViewController ??= PageController(initialPage: 0),
                              count: (topRatedMovies.isNotEmpty) ? (topRatedMovies.length > 5 ? 5 : topRatedMovies.length) : 1,
                              axisDirection: Axis.horizontal,
                              onDotClicked: (i) async {
                                if (_model.pageViewController != null && _model.pageViewController!.hasClients) {
                                  await _model.pageViewController!.animateToPage(
                                    i,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease,
                                  );
                                }
                                safeSetState(() {});
                              },
                              effect: smooth_page_indicator.SlideEffect(
                                spacing: 8,
                                radius: 8,
                                dotWidth: 8,
                                dotHeight: 8,
                                dotColor: FlutterFlowTheme.of(context).accent1,
                                activeDotColor: FlutterFlowTheme.of(context).primary,
                                paintStyle: PaintingStyle.fill,
                              ),
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Rated',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              letterSpacing: 0.0,
                            ),
                      ),
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => MoviesListPage(
                                title: 'Top rated movies', 
                                movies: topRatedMovies,)
                            )
                          )
                        },
                        child: Text(
                          'See all >',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 224,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: AlwaysScrollableScrollPhysics(), 
                    itemCount: topRatedMovies.length > 10 ? 10 : topRatedMovies.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                        child: wrapWithModel(
                          model: _model.movieCardModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: MovieCardWidget(
                            image: 'https://image.tmdb.org/t/p/w500${topRatedMovies[index]['poster_path']}', 
                            title: topRatedMovies[index]['title'], 
                            language: topRatedMovies[index]['original_language'], 
                            rating: topRatedMovies[index]['vote_average'].toDouble(),
                            movieId: topRatedMovies[index]['id'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Popular',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              letterSpacing: 0.0,
                            ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => MoviesListPage(
                                title: 'Top rated movies', 
                                movies: popularMovies,)
                            )
                          );
                        },
                        child: Text(
                          'See all >',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 224,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: AlwaysScrollableScrollPhysics(), 
                    itemCount: popularMovies.length > 10 ? 10 : popularMovies.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 2, 0),
                        child: wrapWithModel(
                          model: _model.movieCardModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: MovieCardWidget(
                            image: 'https://image.tmdb.org/t/p/w500${popularMovies[index]['poster_path']}', 
                            title: popularMovies[index]['title'], 
                            language: popularMovies[index]['original_language'], 
                            rating: popularMovies[index]['vote_average'].toDouble(),
                            movieId: popularMovies[index]['id'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      ),
    );
  }
}
