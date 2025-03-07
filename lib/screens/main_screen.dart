import 'package:dashboard/widgets/result_widget.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dashboard/const/constant.dart';
import 'package:dashboard/screens/main_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';



class MainScreen extends StatelessWidget{
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                flex:1,
                child: Container(color: Colors.red),
            ),
            Expanded(
              flex:3,
              child: Container(color: Colors.pink),
            ),
            Expanded(
              flex:7,
              child: SizedBox(
                child: ResultWidget(),
              ),
            ),],
        ),
      )
    );
  }
}