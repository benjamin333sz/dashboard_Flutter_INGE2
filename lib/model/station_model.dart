class StationModel {
  final String code_station;
  final String code_region;
  final String libelle_station;
  final String libelle_commune;
  final String libelle_region;
  final double latitude;
  final double longitude;
  List<Prelevement> prelevements;

  StationModel({
    required this.code_station,
    required this.libelle_station,
    required this.libelle_commune,
    required this.libelle_region,
    required this.latitude,
    required this.longitude,
    required this.code_region,
    List<Prelevement>? prelevements,
  }) : prelevements = prelevements ?? [];

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      code_station: json['code_station'] ?? '',
      libelle_station: json['libelle_station'] ?? '',
      libelle_commune: json['libelle_commune'] ?? '',
      libelle_region: json['libelle_region'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      code_region: json['code_region'] ?? '',
      prelevements: [],
    );
  }

  StationModel copyWith({List<Prelevement>? prelevements}) {
    return StationModel(
      code_station: code_station,
      libelle_station: libelle_station,
      libelle_commune: libelle_commune,
      libelle_region: libelle_region,
      latitude: latitude,
      longitude: longitude,
      prelevements: prelevements ?? this.prelevements,
      code_region: code_region,
    );
  }
}

class Prelevement {
  final DateTime date_operation;
  final String ipr_code_classe;
  final String ipr_libelle_classe;
  final String libelle_station;
  final String code_station;
  final String code_region;

  Prelevement({
    required this.date_operation,
    required this.ipr_code_classe,
    required this.ipr_libelle_classe,
    required this.libelle_station,
    required this.code_station,
    required this.code_region,

  });

  factory Prelevement.fromJson(Map<String, dynamic> json) {

    DateTime date_operation;
    try {
      date_operation = DateTime.parse(json['date_operation']);
    } catch (e) {

      print('❌ Erreur de conversion de la date : ${json['date_operation']}');
      date_operation = DateTime.now();
    }

    return Prelevement(

      date_operation: DateTime.parse(json['date_operation']),
      ipr_code_classe: json['ipr_code_classe'] ?? '',
      ipr_libelle_classe: json['ipr_libelle_classe'] ?? '',
      libelle_station: json['libelle_station'] ?? '',
      code_station: json['code_station'] ?? '',
      code_region: json['code_region'] ?? '',
    );
  }

}

