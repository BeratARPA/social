import 'dart:convert';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String username;
  final DateTime expiresAt;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.username,
    required this.expiresAt,
  });

  factory AuthResponseModel.fromRawJson(String str) => AuthResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => AuthResponseModel(
    accessToken: json["accessToken"],
    refreshToken: json["refreshToken"],
    username: json["username"],
    expiresAt: DateTime.parse(json["expiresAt"]),
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "refreshToken": refreshToken,
    "username": username,
    "expiresAt": expiresAt.toIso8601String(),
  };
}