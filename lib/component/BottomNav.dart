import 'package:flutter/material.dart';
import '../pages/HomePage.dart';
import '../pages/ProfilePage.dart';
import '../pages/MarkPage.dart';
import '../pages/SearchPage.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onItemTapped(int index) {
    if (index == widget.currentIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const HomePageWidget();
        break;
      case 1:
        nextPage = const SearchPageWidget();
        break;
      case 2:
        nextPage = const MarkPageWidget();
        break;
      case 3:
        nextPage = const ProfilePageWidget();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
      padding: const EdgeInsets.symmetric(vertical: 5), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30), 
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, 
          selectedItemColor: Color.fromARGB(255, 202, 30, 39),
          unselectedItemColor: Colors.grey,
          selectedIconTheme: const IconThemeData(size: 26), 
          unselectedIconTheme: const IconThemeData(size: 24),
          elevation: 0, 
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 20),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 20),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark, size: 20),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 20),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
