import 'dart:convert';

class VerifyCodeResponseModel {
  final bool isSuccess;
  final String? actionToken;

  VerifyCodeResponseModel({required this.isSuccess, this.actionToken});

  factory VerifyCodeResponseModel.fromRawJson(String str) =>
      VerifyCodeResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VerifyCodeResponseModel.fromJson(Map<String, dynamic> json) =>
      VerifyCodeResponseModel(
        isSuccess: json["isSuccess"],
        actionToken: json["actionToken"],
      );

  Map<String, dynamic> toJson() => {
    "isSuccess": isSuccess,
    "actionToken": actionToken,
  };
}
