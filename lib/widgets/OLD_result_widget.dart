
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/OLD_fish_provider.dart';
import '../model/OLD_prelevement_model.dart';
import '../providers/Data_provider.dart';



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


@override
  Widget build(BuildContext context){
    final fishData=ref.watch(fishDataProvider);
    final fishNotifier = ref.watch(fishDataProvider.notifier);
    final hasMoreData = ref.watch(fishDataProvider.notifier).hasMoreData;

  if (fishData.isEmpty) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

    final Map<String, List<ResultModel>> groupedData = {};
    for (var fish in fishData) {
      groupedData.putIfAbsent(fish.libelleStation, () => []).add(fish);
    }

    final stationNames = groupedData.keys.toList();
    final itemCount = stationNames.length + (hasMoreData ? 1 : 0);

    return Scaffold(
      body: ListView.builder(
        controller: _scrollController,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= stationNames.length) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ));
          }

          final stationName = stationNames[index];
          final stationData = groupedData[stationName]!;
          debugPrint('Station: $stationName - Nombre de prélèvements: ${stationData.length}');

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

            elevation: 5,
            child: ExpansionTile(
              title: Text(stationName, style: const TextStyle(fontWeight: FontWeight.bold)),
              onExpansionChanged: (isExpanded) {
                if (isExpanded) {
                  fishNotifier.fetchStationData(stationName);
                }
              },
              children: stationData.map((fish) {
                return Column(
                  children: [
                    ListTile(
                      title: Text('Commune : ${fish.libelleCommune }'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date : ${fish.dateOperation.split("T")[0]}'),
                          Text('Code Classe : ${fish.ipr_code_classe }'),
                          Text('Libellé Classe : ${fish.ipr_libelle_classe }'),
                        ],
                      ),
                    ),
                    Divider(),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
}

}
