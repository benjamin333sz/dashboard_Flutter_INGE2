import 'package:flutter/cupertino.dart';

import 'header_widget.dart';

class ResearchWidget extends StatelessWidget{
  const ResearchWidget({super.key});

  @override
  Widget build(BuildContext context){
    return const Column(
      children: [
        const SizedBox(height:18),
        const HeaderWidget(),
      ],
    );
  }
}