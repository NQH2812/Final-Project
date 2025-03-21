
import '/flutter_flow/flutter_flow_util.dart';
import 'package:movie_app/pages/MovieDetails.dart' show DetailsWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class DetailsModel extends FlutterFlowModel<DetailsWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    expandableExpandableController.dispose();
  }
}
