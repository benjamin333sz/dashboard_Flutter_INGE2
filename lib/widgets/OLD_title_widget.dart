import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget{
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context){
    return Expanded(
      child: Text(
          'Présentations stations',
        style: TextStyle(fontSize: 24),
        textAlign: TextAlign.center,

      ),
    );
  }
}