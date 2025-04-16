import 'package:dashboard/const/constant.dart';
import '../model/station_model.dart';

double calculerMoyenneIPRParAnnee(List<Prelevement> prelevements, List<int> annees) {
  List<double> valeursIPR = prelevements
      .where((p) => annees.contains(p.date_operation.year))
      .map((p) => double.tryParse(p.ipr_code_classe) ?? 0.0)
      .where((ipr) => ipr > 0)
      .toList();

  if (valeursIPR.isEmpty) return 0.0;

  return valeursIPR.reduce((a, b) => a + b) / valeursIPR.length;
}

Map<String, List<Prelevement>> regrouperPrelevementsParRegion(List<StationModel> stations) {
  Map<String, List<Prelevement>> prelevementsParRegion = {};

  for (var station in stations) {
    String codeReg = station.code_region;
    String? region = correspondanceRegions[codeReg];

    if (region != null) {
      prelevementsParRegion.putIfAbsent(region, () => []);
      prelevementsParRegion[region]!.addAll(station.prelevements);
    }
  }

  return prelevementsParRegion;
}

Map<String, double> calculerMoyenneParRegionAvecFiltre(List<StationModel> stations, List<int> annees) {
  Map<String, List<Prelevement>> prelevementsParRegion = regrouperPrelevementsParRegion(stations);
  return prelevementsParRegion.map((region, prelevements) =>
      MapEntry(region, calculerMoyenneIPRParAnnee(prelevements, annees)));
}
