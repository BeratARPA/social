import 'package:social/enums/http_method.dart';
import 'package:social/enums/verification_channel.dart';
import 'package:social/enums/verification_type.dart';
import 'package:social/helpers/app_constant.dart';
import 'package:social/models/auth_response_model.dart';
import 'package:social/models/social_endpoint.dart';
import 'package:social/models/verify_code_response_model.dart';
import 'package:social/services/http_client_service.dart';

class SocialApiService {
  HttpClientService httpClient = HttpClientService(
    baseUrl: SocialEndpoint.baseUrl,
  );

  Future<ApiResult<AuthResponseModel>> register(
    String username,
    String email,
    String password,
  ) async {
    var response = await httpClient.sendRequest<AuthResponseModel>(
      HttpMethod.post,
      SocialEndpoint.register,
      body: {"username": username, "email": email, "password": password},
      fromJson: (json) => AuthResponseModel.fromJson(json),
    );

    if (response.isSuccess) {
      AppConstant.currentAuth = response.data;
    }

    return response;
  }

  Future<ApiResult<AuthResponseModel>> login(
    String username,
    String password,
  ) async {
    var response = await httpClient.sendRequest<AuthResponseModel>(
      HttpMethod.post,
      SocialEndpoint.login,
      body: {"username": username, "password": password},
      fromJson: (json) => AuthResponseModel.fromJson(json),
    );

    if (response.isSuccess) {
      AppConstant.currentAuth = response.data;
    }

    return response;
  }

  Future<ApiResult<AuthResponseModel>> refreshToken() async {
    var response = await httpClient.sendRequest<AuthResponseModel>(
      HttpMethod.post,
      SocialEndpoint.refreshToken,
      token: AppConstant.currentAuth?.accessToken ?? "",
      body: {"refreshToken": refreshToken},
      fromJson: (json) => AuthResponseModel.fromJson(json),
    );

    if (response.isSuccess) {
      AppConstant.currentAuth = response.data;
    }

    return response;
  }

  Future<ApiResult<bool>> logout() async {
    var response = await httpClient.sendRequest<bool>(
      HttpMethod.post,
      SocialEndpoint.logout,
      token: AppConstant.currentAuth?.accessToken ?? "",
      body: {"refreshToken": refreshToken},
    );

    if (response.isSuccess) {
      AppConstant.currentAuth = null;
    }

    return response;
  }

  Future<ApiResult<bool>> sendVerification(
    VerificationChannel verificationChannel,
    VerificationType verificationType,
    String target,
  ) async {
    var response = await httpClient.sendRequest<bool>(
      HttpMethod.post,
      SocialEndpoint.sendVerification,
      body: {
        "verificationChannel": verificationChannel.index,
        "verificationType": verificationType.index,
        "target": target,
      },
    );

    return response;
  }

  Future<ApiResult<VerifyCodeResponseModel>> verifyCode(
    VerificationChannel verificationChannel,
    VerificationType verificationType,
    String target,
    String code,
  ) async {
    var response = await httpClient.sendRequest<VerifyCodeResponseModel>(
      HttpMethod.post,
      SocialEndpoint.verifyCode,
      body: {
        "verificationChannel": verificationChannel.index,
        "verificationType": verificationType.index,
        "target": target,
        "code": code,
      },
      fromJson: (json) => VerifyCodeResponseModel.fromJson(json),
    );

    return response;
  }

  Future<ApiResult<bool>> forgotPassword(
    String actionToken,
    String email,
    String newPassword,
    String confirmPassword,
  ) async {
    var response = await httpClient.sendRequest<bool>(
      HttpMethod.post,
      SocialEndpoint.forgotPassword,
      body: {
        "actionToken": actionToken,
        "email": email,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      },
    );

    return response;
  }

  Future<ApiResult<bool>> resetPassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    var response = await httpClient.sendRequest<bool>(
      HttpMethod.post,
      SocialEndpoint.resetPassword,
      body: {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      },
    );

    return response;
  }

  Future<bool> enable2FA() async {
    return true;
  }
}
