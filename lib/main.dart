import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/view/main_page.dart';
import './constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter<Task>(TaskAdapter());
  await Hive.openBox<Task>('tasksBox');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false; 

  @override
  void initState() {
    super.initState();
    _loadThemePreference(); 
  }

  void _loadThemePreference() async {
    final box =
        await Hive.openBox('settingsBox'); 
    setState(() {
      _isDarkMode =
          box.get('darkMode', defaultValue: false); 
    });
  }

  void _toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode; 
    });

    final box = await Hive.openBox('settingsBox'); 
    await box.put('darkMode', _isDarkMode); 
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? _darkTheme() : _lightTheme(),
      debugShowCheckedModeBanner: false,
      home: MainPage(
        toggleTheme: _toggleTheme, 
        isDarkMode: _isDarkMode, 
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      useMaterial3: true,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSans(
            fontSize: 32, fontWeight: FontWeight.bold, color: darkBlue),
        displayMedium: GoogleFonts.dmSans(
            fontSize: 28, fontWeight: FontWeight.bold, color: darkBlue),
        titleLarge: GoogleFonts.dmSans(
            fontSize: 24, fontWeight: FontWeight.bold, color: darkBlue),
        titleMedium: GoogleFonts.dmSans(
            fontSize: 20, fontWeight: FontWeight.w500, color: darkBlue),
        bodyMedium: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w500, color: darkBlue),
        labelMedium: GoogleFonts.dmSans(fontSize: 14, color: darkGreyColor),
        labelSmall: GoogleFonts.dmSans(fontSize: 12),
      ),
      iconTheme: const IconThemeData(size: 28),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryColor,
        disabledColor: greyColor,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(primary: primaryColor),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      primaryColor: Colors.grey[900],
      useMaterial3: true,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSans(
            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: GoogleFonts.dmSans(
            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: GoogleFonts.dmSans(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        titleMedium: GoogleFonts.dmSans(
            fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        bodyMedium: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        labelMedium: GoogleFonts.dmSans(fontSize: 14, color: Colors.white70),
        labelSmall: GoogleFonts.dmSans(fontSize: 12),
      ),
      iconTheme: const IconThemeData(size: 28),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryColor,
        disabledColor: greyColor,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(primary: primaryColor),
    );
  }
}
