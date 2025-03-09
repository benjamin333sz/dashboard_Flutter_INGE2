class ResultModel {
  final String codeOperation;
  final String dateOperation;
  final String libelleStation;
  final String codeStation;
  final String libelleCommune;
  final String libelleRegion;

  ResultModel({
    required this.codeOperation,
    required this.dateOperation,
    required this.libelleStation,
    required this.codeStation,
    required this.libelleCommune,
    required this.libelleRegion,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      codeOperation: json['code_operation'] ?? '',
      dateOperation: json['date_operation'] ?? '',
      libelleStation: json['libelle_station'] ?? '',
      codeStation: json['code_station'] ?? '',
      libelleCommune: json['libelle_commune'] ?? '',
      libelleRegion: json['libelle_region'] ?? '',
    );
  }
}

