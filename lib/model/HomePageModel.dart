import 'dart:async';
import 'package:movie_app/component/MovieCard.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:movie_app/service/package.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  PageController? pageViewController;
  Timer? autoScrollTimer;
  
  int get pageViewCurrentIndex => pageViewController?.hasClients == true
      ? (pageViewController?.page?.round() ?? 0)
      : 0;
  late MovieCardModel movieCardModel1;
  late MovieCardModel movieCardModel2;

  @override
  void initState(BuildContext context) {
    movieCardModel1 = createModel(context, () => MovieCardModel());
    movieCardModel2 = createModel(context, () => MovieCardModel());

    pageViewController = PageController();
    startAutoScroll();
    pageViewController?.addListener(() {
      resetAutoScrollTimer();
    });
  }

  void startAutoScroll() {
    autoScrollTimer?.cancel();
    autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (pageViewController?.hasClients == true) {
        int itemCount = 5; 
        int nextPage = (pageViewCurrentIndex + 1) % itemCount;
        pageViewController?.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void resetAutoScrollTimer() {
    autoScrollTimer?.cancel();
    startAutoScroll();
  }

  @override
  void dispose() {
    autoScrollTimer?.cancel();
    pageViewController?.dispose();
    movieCardModel1.dispose();
    movieCardModel2.dispose();
  }
}
