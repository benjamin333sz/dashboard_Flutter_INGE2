import '../model/station_model.dart';

Map<int, double> calculerEvolutionIPRFrance(List<StationModel> stations) {
  Map<int, List<double>> iprParAnnee = {};

  for (var station in stations) {
    // Détection des stations fantômes
    bool isGhostStation =
        station.libelle_station.trim().isEmpty &&
            station.prelevements.length >= 100 &&
            station.prelevements.every((p) => p.date_operation == station.prelevements.first.date_operation);

    if (isGhostStation) continue; // On ignore les stations fantômes

    for (var prelevement in station.prelevements) {
      int annee = prelevement.date_operation.year;
      double ipr = double.tryParse(prelevement.ipr_code_classe) ?? 0.0;

      if (ipr > 0) {
        iprParAnnee.putIfAbsent(annee, () => []);
        iprParAnnee[annee]!.add(ipr);
      }
    }
  }

  return iprParAnnee.map((annee, valeurs) =>
      MapEntry(annee, valeurs.reduce((a, b) => a + b) / valeurs.length));
}





