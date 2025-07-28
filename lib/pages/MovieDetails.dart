import 'dart:async'; 
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:movie_app/flutter_flow/flutter_flow_model.dart';
import 'package:movie_app/flutter_flow/flutter_flow_theme.dart';
import 'package:movie_app/service/api.dart';
import 'package:movie_app/model/DetailsModel.dart';
import 'package:movie_app/service/package.dart';
import '../service/provider.dart';
import '../service/adsBlock.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DetailsWidget extends StatefulWidget {
  final int movieId;
  const DetailsWidget({super.key, required this.movieId});

  @override
  State<DetailsWidget> createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<DetailsWidget> {
  late DetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Movie data state
  Map<String, dynamic>? movieDetails;
  String? _videoKey;
  
  // Loading and error states
  bool _isLoading = true;
  String? _errorMessage;

  // Player state management
  YoutubePlayerController? _youtubeController;
  WebViewController? _webViewController;
  bool _isVideoReady = false;
  bool _isFullScreen = false;
  bool _showTrailer = false;
  bool _showMovie = false;
  
  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetailsModel());
    _model.expandableExpandableController = ExpandableController(initialExpanded: false);
    
    // Set portrait orientation on init
    _setPortraitOrientation();
    
    // Fetch movie data
    fetchMovieDetails();
  }

  // Set portrait orientation
  void _setPortraitOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Set landscape orientation
  void _setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  // Reset orientation to system default
  void _resetOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // Initialize WebView controller with enhanced security (lazy loading)
  void _initWebViewController() {
    _webViewController = WebSecurityHelper.initSecuredWebViewController(widget.movieId);
  }

  // Fetch movie details from API
  Future<void> fetchMovieDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final details = await MovieService.fetchMovieDetails(widget.movieId);
      final videoKey = await MovieService.fetchMovieVideo(widget.movieId);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          movieDetails = details;
          _videoKey = videoKey;
          
          // Initialize YouTube player if video key is available
          if (_videoKey != null && _videoKey!.isNotEmpty) {
            _initializeYoutubePlayer(_videoKey!);
            _isVideoReady = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load movie details. Please try again.";
          print("Error fetching movie details: $e");
        });
      }
    }
  }

  // Initialize YouTube player with video ID
  void _initializeYoutubePlayer(String videoId) {
    // Dispose existing controller if any
    _youtubeController?.dispose();

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );

    _youtubeController!.addListener(_handleYoutubePlayerStateChanges);
  }
  
  // Handle YouTube player state changes
  void _handleYoutubePlayerStateChanges() {
    if (_youtubeController == null || !mounted) return;
    
    // Update video ready state
    if (_youtubeController!.value.isReady && !_isVideoReady) {
      setState(() {
        _isVideoReady = true;
      });
    }
    
    // Handle fullscreen changes
    if (_youtubeController!.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = _youtubeController!.value.isFullScreen;
        _handleFullScreenChange();
      });
    }
  }

  // Handle full screen state changes
  void _handleFullScreenChange() {
    if (_isFullScreen) {
      _setLandscapeOrientation();
    } else {
      _setPortraitOrientation();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
  
  // Toggle trailer view
  void _toggleTrailer() {
    setState(() {
      _showTrailer = !_showTrailer;
      if (_showTrailer) {
        _showMovie = false;
      }
    });
  }
  
  // Toggle movie view with safety monitoring
  void _toggleMovie() {
    setState(() {
      _showMovie = !_showMovie;
      if (_showMovie) {
        _showTrailer = false;
        // Lazy initialize WebView
        if (_webViewController == null) {
          _initWebViewController();
        } else {
          // Apply ad blocking when movie is shown
          WebSecurityHelper.injectAdBlockingCSS(_webViewController);
        }
        
        // Set up a periodic security check when movie is playing
        _startSecurityMonitoring();
      } else {
        // Stop monitoring when player is closed
        _stopSecurityMonitoring();
      }
    });
  }
  
  // Timer for periodic security checks
  Timer? _securityTimer;
  
  // Start periodic security monitoring for the WebView
  void _startSecurityMonitoring() {
    // Clear any existing timer
    _stopSecurityMonitoring();
    
    // Check every 5 seconds for suspicious activity
    _securityTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_webViewController != null && _showMovie) {
        WebSecurityHelper.checkForSuspiciousActivity(_webViewController);
      } else {
        // Stop monitoring if player is no longer active
        _stopSecurityMonitoring();
      }
    });
  }
  
  // Stop security monitoring
  void _stopSecurityMonitoring() {
    _securityTimer?.cancel();
    _securityTimer = null;
  }

  // Handle back button press
  Future<bool> _handleBackButton() async {
    if (_isFullScreen) {
      // Exit fullscreen instead of navigating back
      _youtubeController?.toggleFullScreenMode();
      return false;
    }
    
    // Close video players instead of navigating back
    if (_showTrailer || _showMovie) {
      setState(() {
        _showTrailer = false;
        _showMovie = false;
      });
      return false;
    }
    
    return true; // Allow normal back navigation
  }

  @override
  void dispose() {
    // Reset orientation and UI mode
    _resetOrientation();
    
    // Clean up controllers and timers
    _stopSecurityMonitoring();
    _youtubeController?.removeListener(_handleYoutubePlayerStateChanges);
    _youtubeController?.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackButton,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: _isFullScreen 
              ? null  // Hide AppBar in fullscreen mode
              : AppBar(
                  backgroundColor: const Color.fromARGB(255, 202, 30, 39),
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () {
                      if (_showTrailer || _showMovie) {
                        setState(() {
                          _showTrailer = false;
                          _showMovie = false;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: Text(
                    movieDetails?['title'] ?? 'Movie Details',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  centerTitle: true,
                  elevation: 0,
                ),
        body: _isLoading 
            // Loading indicator
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color.fromARGB(255, 202, 30, 39),
                    ),
                    SizedBox(height: 16),
                    Text('Loading movie details...'),
                  ],
                ),
              )
            // Error message
            : _errorMessage != null 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: fetchMovieDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 202, 30, 39),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              // Fullscreen player
              : _isFullScreen 
                ? Center(
                    child: YoutubePlayer(
                      controller: _youtubeController!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: const Color.fromARGB(255, 202, 30, 39),
                      progressColors: const ProgressBarColors(
                        playedColor: Color.fromARGB(255, 202, 30, 39),
                        handleColor: Color.fromARGB(255, 202, 30, 39),
                      ),
                      bottomActions: [
                        CurrentPosition(),
                        ProgressBar(
                          isExpanded: true,
                          colors: const ProgressBarColors(
                            playedColor: Color.fromARGB(255, 202, 30, 39),
                            handleColor: Color.fromARGB(255, 202, 30, 39),
                          ),
                        ),
                        RemainingDuration(),
                        const PlaybackSpeedButton(),
                        FullScreenButton(),
                      ],
                    ),
                  )
                // Regular content
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
                                      const SizedBox(height: 15),
                                      
                                      // Media container
                                      Column(
                                        children: [
                                          Container(
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
                                              child: _showTrailer && _isVideoReady && _youtubeController != null
                                                // Show YouTube trailer
                                                ? YoutubePlayer(
                                                    controller: _youtubeController!,
                                                    showVideoProgressIndicator: true,
                                                    progressIndicatorColor: const Color.fromARGB(255, 202, 30, 39),
                                                    progressColors: const ProgressBarColors(
                                                      playedColor: Color.fromARGB(255, 202, 30, 39),
                                                      handleColor: Color.fromARGB(255, 202, 30, 39),
                                                    ),
                                                    onReady: () {
                                                      if (_youtubeController!.value.isReady) {
                                                        setState(() {
                                                          _isVideoReady = true;
                                                        });
                                                      }
                                                    },
                                                    bottomActions: [
                                                      CurrentPosition(),
                                                      ProgressBar(
                                                        isExpanded: true,
                                                        colors: const ProgressBarColors(
                                                          playedColor: Color.fromARGB(255, 202, 30, 39),
                                                          handleColor: Color.fromARGB(255, 202, 30, 39),
                                                        ),
                                                      ),
                                                      RemainingDuration(),
                                                      const PlaybackSpeedButton(),
                                                      FullScreenButton(),
                                                    ],
                                                  )
                                                // Show WebView movie player
                                                : _showMovie && _webViewController != null
                                                  ? WebViewWidget(
                                                      controller: _webViewController!,
                                                    )
                                                  // Show movie poster (default)
                                                  : Image.network(
                                                      movieDetails?['poster_path'] != null
                                                          ? 'https://image.tmdb.org/t/p/w500${movieDetails!['poster_path']}'
                                                          : 'https://via.placeholder.com/500x750.png?text=No+Image',
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.fill,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Center(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                                              SizedBox(height: 8),
                                                              Text("Image not available"),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (loadingProgress == null) return child;
                                                        return Center(
                                                          child: CircularProgressIndicator(
                                                            value: loadingProgress.expectedTotalBytes != null
                                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                                : null,
                                                            color: const Color.fromARGB(255, 202, 30, 39),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ),
                                          ),
                                          
                                          // Show security notice when web player is active
                                          if (_showMovie)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.security, size: 16, color: Colors.green),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      'Enhanced protection active: Blocking ads and suspicious redirects',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Action buttons
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Trailer button
                                          ElevatedButton.icon(
                                            onPressed: _isVideoReady ? () => _toggleTrailer() : null,
                                            icon: Icon(_showTrailer ? Icons.close : Icons.play_circle_outline),
                                            label: Text(_showTrailer ? 'Close Trailer' : 'Trailer'),
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: const Color.fromARGB(255, 202, 30, 39),
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              disabledForegroundColor: Colors.white.withOpacity(0.5),
                                              disabledBackgroundColor: const Color.fromARGB(255, 202, 30, 39).withOpacity(0.5),
                                            ),
                                          ),
                                          
                                          // Watch Movie button
                                          ElevatedButton.icon(
                                            onPressed: () => _toggleMovie(),
                                            icon: Icon(_showMovie ? Icons.close : Icons.movie),
                                            label: Text(_showMovie ? 'Close Player' : 'Watch Movie'),
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: const Color.fromARGB(255, 30, 114, 202),
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Movie metadata
                                      Row(
                                        children: [
                                          // Release date
                                          const Icon(Icons.calendar_today_rounded, color: Color.fromARGB(255, 202, 30, 39)),
                                          const SizedBox(width: 4),
                                          Text(
                                            movieDetails?['release_date'] ?? "N/A",
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                          ),
                                          
                                          // Rating
                                          const SizedBox(width: 10),
                                          const Icon(Icons.star, color: Color(0xFFFFD300), size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${movieDetails?['vote_average']?.toDouble()?.toStringAsFixed(1) ?? "N/A"}',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          
                                          // Favorite/bookmark button
                                          const Spacer(),
                                          Consumer<FavoriteMoviesProvider>(
                                            builder: (context, favoriteProvider, child) {
                                              final isFav = favoriteProvider.isFavorite(widget.movieId);
                                              return IconButton(
                                                onPressed: () {
                                                  if (movieDetails != null) {
                                                    favoriteProvider.toggleFavorite(movieDetails!);
                                                  }
                                                },
                                                icon: Icon(
                                                  isFav ? Icons.bookmark : Icons.bookmark_border,
                                                  color: isFav ? Colors.red : Colors.black,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Movie overview
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
      ),
    );
  }
}