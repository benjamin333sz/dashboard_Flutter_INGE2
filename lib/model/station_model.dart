class StationModel {
  final String codeStation;
  final String libelleStation;
  final String libelleCommune;
  final String libelleRegion;
  final double latitude;
  final double longitude;

  StationModel({
    required this.codeStation,
    required this.libelleStation,
    required this.libelleCommune,
    required this.libelleRegion,
    required this.latitude,
    required this.longitude,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      codeStation: json['code_station'] ?? '',
      libelleStation: json['libelle_station'] ?? '',
      libelleCommune: json['libelle_commune'] ?? '',
      libelleRegion: json['libelle_region'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }
}
