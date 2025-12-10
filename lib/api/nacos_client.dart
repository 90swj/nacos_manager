import 'package:dio/dio.dart';  
  
class NacosClient {  
  static final NacosClient _instance = NacosClient._internal();  
  late Dio _dio;  
  String? _accessToken;  
  
  factory NacosClient() => _instance;  
  
  NacosClient._internal() {  
    _dio = Dio(BaseOptions(  
      connectTimeout: const Duration(seconds: 10),  
      receiveTimeout: const Duration(seconds: 10),  
      responseType: ResponseType.json,  
    ));  
  
    // 拦截器：自动添加 accessToken  
    _dio.interceptors.add(InterceptorsWrapper(  
      onRequest: (options, handler) {  
        if (_accessToken != null) {  
          options.queryParameters['accessToken'] = _accessToken;  
        }  
        return handler.next(options);  
      },  
      onError: (DioException e, handler) {  
        // 可以在这里处理 403 Token 过期自动登出  
        return handler.next(e);  
      },  
    ));  
  }  
  
  // 初始化：切换环境时调用  
  void init(String baseUrl) {  
    // 去除末尾斜杠  
    if (baseUrl.endsWith("/")) {  
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);  
    }  
    _dio.options.baseUrl = baseUrl;  
    _accessToken = null; // 切换环境需重置 token  
  }  
  
  // 登录  
  Future<bool> login(String username, String password) async {  
    try {  
      final response = await _dio.post(  
        '/nacos/v1/auth/users/login',  
        data: {'username': username, 'password': password},  
        options: Options(contentType: Headers.formUrlEncodedContentType),  
      );  
  
      if (response.statusCode == 200) {  
        _accessToken = response.data['accessToken'];  
        return true;  
      }  
      return false;  
    } catch (e) {  
      print("Login Error: $e");  
      return false;  
    }  
  }  
  
  Dio get dio => _dio;  
}  
