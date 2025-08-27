import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'api_client.dart';

/// ChatGPT: Intercepts 401, attempts one refresh, retries request once.
class AuthInterceptor extends Interceptor {
  bool _refreshing = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_refreshing) {
      _refreshing = true;
      final ok = await AuthRepository().tryRefreshTokensFromInterceptor();
      _refreshing = false;
      if (ok) {
        // Re-attach fresh access token
        final access = await AuthRepository().getAccessToken();
        if (access != null) {
          ApiClient.setBearer(access);
        }
        // Retry once
        final req = err.requestOptions;
        try {
          final clone = await ApiClient.dio.fetch(req);
          return handler.resolve(clone);
        } catch (e) {
          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }
}