import 'package:dashboard/const/constant.dart';
import 'package:dashboard/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// RECUPERER CODE SUR GITHUB: git pull

void main() {
  // debugPaintSizeEnabled=true;
  runApp(
      ProviderScope(
      child: MyApp(),
      )
  );
  // test de push version terminus
  // git checkout -b <main>
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Données Poissons',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.light,
      ),
      home: const MainScreen(),
    );
  }
}

