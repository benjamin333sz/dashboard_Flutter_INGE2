import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/result_data.dart';
import '../model/result_model.dart';
import '../providers/fish_provider.dart';
import '../widgets/header_widget.dart';

class ResultWidget extends ConsumerStatefulWidget {
  const ResultWidget({super.key});

  @override
  ConsumerState<ResultWidget> createState() => _ResultWidgetState();
}
class _ResultWidgetState extends ConsumerState<ResultWidget> {
  late ScrollController _scrollController;

  @override
  void initState(){
    super.initState();
    _scrollController=ScrollController();
    _scrollController.addListener(_scrollListener);

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      ref.read(fishDataProvider.notifier).fetchMoreData();
    }
  }

  Timer? _debounce;
@override
  Widget build(BuildContext context){
    final fishData=ref.watch(fishDataProvider);
    final hasMoreData = ref.watch(fishDataProvider.notifier).hasMoreData;

    return Scaffold(
      body: fishData.isEmpty
          ?Center(

            child:
            CircularProgressIndicator())
          :ListView.builder(
            controller: _scrollController,
            itemCount: fishData.length +(hasMoreData ? 1 : 0),
            itemBuilder: (context,index){
            if (index == fishData.length) {
              return null;

          }
          final fish=fishData[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                        title: Text(fish.libelleStation ?? 'Station inconnue',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Commune : ${fish.libelleCommune ?? "N/A"} \n libelle_Station : ${fish.libelleStation} \n codeStation : ${fish.codeStation} \n ipr_code_classe : ${fish.ipr_code_classe ?? "N/A"} \n ipr_libelle_classe : ${fish.ipr_libelle_classe ?? "N/A"}'),

                        trailing: Text(fish.dateOperation.split("T")[0]),
                        ),
          );
        }
      ),
    );
}

}
