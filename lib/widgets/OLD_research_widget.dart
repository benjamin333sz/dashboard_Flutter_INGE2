import 'package:flutter/cupertino.dart';

import 'OLD_header_widget.dart';

class ResearchWidget extends StatelessWidget{
  const ResearchWidget({super.key});

  @override
  Widget build(BuildContext context){
    return  Column(
      children: [
         SizedBox(height:18),
         HeaderWidget(),
      ],
    );
  }
}