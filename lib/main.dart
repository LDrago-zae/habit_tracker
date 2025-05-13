import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/pages/home_page.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/themes/theme_provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) => HabitProvider()..loadData(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
