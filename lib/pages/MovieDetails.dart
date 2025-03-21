import 'package:movie_app/flutter_flow/flutter_flow_model.dart';
import 'package:movie_app/flutter_flow/flutter_flow_theme.dart';
import 'package:movie_app/service/api.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/model/DetailsModel.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailsWidget extends StatefulWidget {
  final int movieId;
  const DetailsWidget({super.key, required this.movieId});

  @override
  State<DetailsWidget> createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<DetailsWidget> {
  late DetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? movieDetails;
  String? _videoKey;
  YoutubePlayerController? _youtubeController;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetailsModel());
    _model.expandableExpandableController = ExpandableController(initialExpanded: false);
    fetchMovieDetails();
  }

  Future<void> fetchMovieDetails() async {
    try {
      final details = await MovieService.fetchMovieDetails(widget.movieId);
      final videoKey = await MovieService.fetchMovieVideo(widget.movieId);

      if (mounted) {
        setState(() {
          movieDetails = details;
          _videoKey = videoKey;
          if (_videoKey != null && _videoKey!.isNotEmpty) {
            initializeYoutubePlayer(_videoKey!);
            _isVideoReady = true;
          } else {
            _isVideoReady = false;
          }
        });
      }
    } catch (e) {
      print("Error fetching movie details: $e");
    }
  }

  void initializeYoutubePlayer(String videoId) {
  _youtubeController?.dispose();

  _youtubeController = YoutubePlayerController(
    initialVideoId: videoId,
    flags: const YoutubePlayerFlags(
      autoPlay: false,
      mute: false,
    ),
  );

  _youtubeController!.addListener(() {
    if (_youtubeController!.value.isReady && mounted) {
      setState(() {
        _isVideoReady = true;
      });
    }
  });

  setState(() {}); 
}


  @override
  void dispose() {
    _youtubeController?.removeListener(() {}); 
    _youtubeController?.dispose();
    _model.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(226, 226, 226, 0.5),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: movieDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movieDetails!['title'] ?? "Unknown",
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        fontFamily: 'Poppins',
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                ),
                                const SizedBox(height: 8),

                                _isVideoReady && _youtubeController != null
                                    ? YoutubePlayerBuilder(
                                        player: YoutubePlayer(
                                          controller: _youtubeController!,
                                          showVideoProgressIndicator: true,
                                          onReady: () {
                                            if (_youtubeController!.value.isReady) {
                                              _youtubeController!.play();
                                            }
                                          },
                                        ),
                                        builder: (context, player) {
                                          return Column(
                                            children: [player],
                                          );
                                        },
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: 230,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: const [
                                            BoxShadow(
                                              blurRadius: 12,
                                              color: Color(0x33000000),
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            movieDetails?['poster_path'] != null
                                                ? 'https://image.tmdb.org/t/p/w500${movieDetails!['poster_path']}'
                                                : 'https://via.placeholder.com/500x750.png?text=No+Image',
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),

                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, color: Colors.red),
                                    Text(
                                      movieDetails?['release_date'] ?? "N/A",
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    const Icon(Icons.star, color: Color(0xFFFFD300), size: 20),
                                    Text(
                                      '${movieDetails?['vote_average']?.toDouble()?.toStringAsFixed(1) ?? "N/A"}',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                ExpandableNotifier(
                                  controller: _model.expandableExpandableController,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Overview',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        movieDetails?['overview'] ?? "No overview available.",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                          color: Color.fromARGB(153, 51, 51, 51),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
