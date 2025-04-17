import 'package:flutter/material.dart';

import '../const/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/OLD_fish_provider.dart';

class HeaderWidget extends ConsumerWidget{
  const HeaderWidget({super.key});
  @override
  Widget build(BuildContext context,WidgetRef ref) {


    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
        color: cardBackgroundColor, // Fond du champ de texte
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.transparent), // Bordure invisible
        ),
     child : Row(
      children: [


        Expanded(
          child: TextField(
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              ref.read(searchProvider.notifier).state = value;
            },
            maxLength: 50,
            decoration: InputDecoration(
              filled: true,
              fillColor: cardBackgroundColor,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide:BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical:5,
              ),
              hintText: 'Recherche',

            ),
          ),
        ),

        const SizedBox(width: 8),
        IconButton(
          icon :Icon(
            Icons.menu,
            color: Colors.black,


          ),
          onPressed: () {
            final searchQuery = ref.read(searchProvider);
            ref.read(fishDataProvider.notifier).resetData(searchQuery);

            //_controller.clear();
          },

        ),
      ],

    )
    );
  }
}