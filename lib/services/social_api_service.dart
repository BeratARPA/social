import 'package:social/enums/http_method.dart';
import 'package:social/helpers/app_constant.dart';
import 'package:social/models/auth_response_model.dart';
import 'package:social/models/social_endpoint.dart';
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

  Future<ApiResult<bool>> sendEmailVerification(String email) async {
    var response = await httpClient.sendRequest<bool>(
      HttpMethod.post,
      SocialEndpoint.sendEmailVerification,
      body: {"email": email},
    );

    return response;
  }

  Future<ApiResult<bool>> verifyEmail(String email, String code) async {
    var response = await httpClient.sendRequest<bool>(
      HttpMethod.post,
      SocialEndpoint.verifyEmail,
      body: {"email": email, "code": code},
    );

    return response;
  }

  Future<ApiResult<bool>> sendPhoneVerification(String phoneNumber) async {
    var response = await httpClient.sendRequest<bool>(
      HttpMethod.post,
      SocialEndpoint.sendPhoneVerification,
      body: {"phoneNumber": phoneNumber},
    );

    return response;
  }

  Future<ApiResult<bool>> verifyPhone(String phoneNumber, String code) async {
    var response = await httpClient.sendRequest<bool>(
      HttpMethod.post,
      SocialEndpoint.verifyPhone,
      body: {"phoneNumber": phoneNumber, "code": code},
    );

    return response;
  }

  Future<bool> enable2FA() async {
    return true;
  }
}
