import 'package:dashboard/graph/grapheFranceIPR.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/station_model.dart';
import '../providers/OLD_fish_provider.dart';
import '../graph/grapheRegionIPR.dart'; // Pour accéder aux fonctions
import '../calcul/France.dart';
import '../calcul/region.dart';

final selectedStationProvider = StateProvider<StationModel?>((ref) => null);
