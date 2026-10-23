import 'dart:convert';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String username;
  final String email;
  final String? phoneNumber;
  final DateTime expiresAt;
  final bool? requiresTwoFactor;
  final String? twoFactorToken;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.username,
    required this.email,
    this.phoneNumber,
    required this.expiresAt,
    this.requiresTwoFactor,
    this.twoFactorToken,
  });

  factory AuthResponseModel.fromRawJson(String str) =>
      AuthResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
        username: json["username"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        expiresAt: DateTime.parse(json["expiresAt"]),
        requiresTwoFactor: json["requiresTwoFactor"],
        twoFactorToken: json["twoFactorToken"],
      );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "refreshToken": refreshToken,
    "username": username,
    "email": email,
    "phoneNumber": phoneNumber,
    "expiresAt": expiresAt.toIso8601String(),
    "requiresTwoFactor": requiresTwoFactor,
    "twoFactorToken": twoFactorToken,
  };
}
