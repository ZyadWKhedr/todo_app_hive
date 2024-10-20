import 'package:flutter/material.dart';
import '../constants.dart';
import 'home_page.dart';
import 'menu.dart';
import 'package:iconsax/iconsax.dart';

class MainPage extends StatefulWidget {
  final VoidCallback toggleTheme; // Callback for toggling theme
  final bool isDarkMode; // Current theme state

  const MainPage({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List pages = [const HomePage(), const MenuPage()];
  int currentIndex = 0;

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo App'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              if (value == 1) {
                widget.toggleTheme(); // Call toggle function for theme
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Toggle Theme'),
                    Switch(
                      value: widget.isDarkMode, // Current theme state
                      onChanged: (value) {
                        widget.toggleTheme(); // Call the toggle function
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: darkGreyColor,
          currentIndex: currentIndex,
          onTap: onTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.home_24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.menu),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}
