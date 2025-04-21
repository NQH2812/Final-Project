import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:movie_app/pages/MovieDetails.dart';
import 'package:movie_app/model/MovieCardModel.dart';
export 'package:movie_app/model/MovieCardModel.dart';

class MovieCardWidget extends StatefulWidget {
  final String image;
  final String title;
  final String language;
  final double rating;
  final int movieId; // Thêm movieId

  const MovieCardWidget({
    super.key,
    required this.image,
    required this.title,
    required this.language,
    required this.rating,
    required this.movieId, // Nhận movieId
  }); 


  @override
  State<MovieCardWidget> createState() => _MovieCardWidgetState();
}

class _MovieCardWidgetState extends State<MovieCardWidget> {
  late MovieCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MovieCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsWidget(movieId: widget.movieId),
            ),
          );
        },
      child: Container(
        width: 115,
        height: 224,
        decoration: BoxDecoration(
          color: Color(0x00B7BCBE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0xFFB0B1B1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero
              ),
              child: Image.network(
                widget.image,
                width: double.infinity,
                height: 172,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
              child: Text(
                widget.title,
                maxLines: 1,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                    child: Text(
                      widget.language,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.star,
                    color: Color(0xFFFFD300),
                    size: 16,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                    child: Text(
                      widget.rating.toStringAsFixed(1),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
