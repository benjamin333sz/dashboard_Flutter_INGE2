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
  List<ResultModel> _fishData = [];
  bool _isLoading = true;
  bool _hasMoreData = true;
  int _page = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchFishData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
        if (_hasMoreData) {
          _fetchFishData();
        }
      }
    });
  }

  Future<void> _fetchFishData() async {
    setState(() {
      _isLoading = true;
    });

    final data = await ResultData.fetchFishData(page: _page);
    setState(() {
      if (data.isEmpty) {
        _hasMoreData = false;
      } else {
        _fishData.addAll(data);
        _page++;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Données Piscicoles")),
      body: _isLoading && _fishData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _fishData.isEmpty
          ? const Center(child: Text("Aucune donnée disponible"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _fishData.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _fishData.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                var fish = _fishData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(fish.libelleStation ?? 'Station inconnue',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Commune : ${fish.libelleCommune ?? "N/A"}'),
                    trailing: Text(fish.dateOperation.split("T")[0]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
