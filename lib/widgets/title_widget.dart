import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget{
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context){
    return Expanded(
      child: TextField(
        decoration: InputDecoration(

            hintText:'Presentations Stations'
        )

      ),
    );
  }
}