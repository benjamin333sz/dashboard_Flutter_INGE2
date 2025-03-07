class ResultModel {
  final String? codeOperation;

  ResultModel({required this.codeOperation});

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(codeOperation: json['code_operation']);
  }
}
