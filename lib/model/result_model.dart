class ResultModel {
  final String codeOperation;
  final String dateOperation;
  final String libelleStation;
  final String codeStation;
  final String libelleCommune;
  final String libelleRegion;
  final String ipr_code_classe;
  final String ipr_libelle_classe;


  ResultModel({
    required this.codeOperation,
    required this.dateOperation,
    required this.libelleStation,
    required this.codeStation,
    required this.libelleCommune,
    required this.libelleRegion,
    required this.ipr_code_classe,
    required this.ipr_libelle_classe,


  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      codeOperation: json['code_operation'] ?? '',
      dateOperation: json['date_operation'] ?? '',
      libelleStation: json['libelle_station'] ?? '',
      codeStation: json['code_station'] ?? '',
      libelleCommune: json['libelle_commune'] ?? '',
      libelleRegion: json['libelle_region'] ?? '',
      ipr_code_classe: json['ipr_code_classe'] ?? '',
      ipr_libelle_classe: json['ipr_libelle_classe'] ?? '',

    );
  }
}

