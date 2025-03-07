import 'dart:async';
import 'dart:convert';
import 'package:dashboard/const/constant.dart';
import 'package:dashboard/screens/main_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// RECUPERER CODE SUR GITHUB: git pull

void main() {
  runApp(const MyApp());
  // test de push
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

