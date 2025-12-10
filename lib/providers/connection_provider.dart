import 'dart:convert';  
import 'package:flutter/material.dart';  
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:dio/dio.dart';  
import 'package:uuid/uuid.dart';  
import '../models/server_profile.dart';  
  
class ConnectionProvider with ChangeNotifier {  
  List<ServerProfile> _profiles = [];  
  List<ServerProfile> get profiles => _profiles;  
    
  Dio? _activeClient;  
  String? _currentAccessToken;  
    
  // 缓存当前的 Namespace 列表，供克隆时选择  
  List<Map<String, dynamic>> _cachedNamespaces = [];  
  List<Map<String, dynamic>> get cachedNamespaces => _cachedNamespaces;  
  
  ConnectionProvider() {  
    _loadProfiles();  
  }  
  
  // --- 基础连接管理 ---  
  
  Future<void> _loadProfiles() async {  
    final prefs = await SharedPreferences.getInstance();  
    final String? data = prefs.getString('nacos_servers');  
    if (data != null) {  
      final List<dynamic> jsonList = jsonDecode(data);  
      _profiles = jsonList.map((e) => ServerProfile.fromJson(e)).toList();  
      notifyListeners();  
    }  
  }  
  
  Future<void> addProfile(String name, String url, String user, String pass) async {  
    final newProfile = ServerProfile(  
      id: const Uuid().v4(),  
      name: name,  
      url: url.endsWith("/") ? url.substring(0, url.length - 1) : url,  
      username: user,  
      password: pass,  
    );  
    _profiles.add(newProfile);  
    await _saveToDisk();  
    notifyListeners();  
  }  
    
  Future<void> removeProfile(String id) async {  
    _profiles.removeWhere((element) => element.id == id);  
    await _saveToDisk();  
    notifyListeners();  
  }  
  
  Future<void> _saveToDisk() async {  
    final prefs = await SharedPreferences.getInstance();  
    final String data = jsonEncode(_profiles.map((e) => e.toJson()).toList());  
    await prefs.setString('nacos_servers', data);  
  }  
  
  // --- Nacos API 交互 ---  
  
  Future<bool> connect(ServerProfile profile) async {  
    try {  
      final options = BaseOptions(  
        baseUrl: profile.url,  
        connectTimeout: const Duration(seconds: 5),  
        receiveTimeout: const Duration(seconds: 10),  
      );  
      final tempDio = Dio(options);  
  
      // 1. 尝试登录  
      final response = await tempDio.post(  
        '/nacos/v1/auth/users/login', // Nacos 1.x/2.x 通用路径  
        queryParameters: {  
          'username': profile.username,  
          'password': profile.password,  
        },  
      );  
  
      if (response.statusCode == 200 && response.data['accessToken'] != null) {  
        _currentAccessToken = response.data['accessToken'];  
          
        _activeClient = Dio(options);  
        _activeClient!.interceptors.add(InterceptorsWrapper(  
          onRequest: (options, handler) {  
            options.queryParameters['accessToken'] = _currentAccessToken;  
            return handler.next(options);  
          },  
        ));  
        return true;  
      }  
      return false;  
    } catch (e) {  
      debugPrint("Login Error: $e");  
      return false;  
    }  
  }  
  
  Future<List<Map<String, dynamic>>> fetchNamespaces() async {  
    try {  
      final response = await _activeClient!.get('/nacos/v1/console/namespaces');  
      final List<dynamic> list = response.data['data'];  
      _cachedNamespaces = list.map((e) => {  
        "namespace": e['namespace'],  
        "namespaceShowName": e['namespaceShowName']  
      }).toList().cast<Map<String, dynamic>>();  
        
      // 确保 Public 存在  
      if (_cachedNamespaces.isEmpty || !_cachedNamespaces.any((e) => e['namespace'] == "" || e['namespace'] == "public")) {  
         _cachedNamespaces.insert(0, {"namespace": "", "namespaceShowName": "public"});  
      }  
      return _cachedNamespaces;  
    } catch (e) {  
      return [{"namespace": "", "namespaceShowName": "public"}];  
    }  
  }  
  
  Future<List<dynamic>> fetchConfigs({
    required String tenant, 
    int pageNo = 1,
    String dataId = '',
    String group = '',
    String appName = '',
    String config_tags = '',
    String type = '',
    String content = '',
  }) async {
    try {
      // 当搜索内容时，使用模糊搜索，否则使用精确搜索
      String searchType = content.isNotEmpty ? 'blur' : 'accurate';
      
      final response = await _activeClient!.get(
        '/nacos/v1/cs/configs',
          queryParameters: {
            'dataId': dataId, 
            'group': group, 
            'appName': appName, 
            'config_tags': config_tags,
            'type': type,
            'content': content,
            'pageNo': pageNo, 
            'pageSize': 50, 
            'tenant': tenant, 
            'search': searchType,
          },
      );
      return response.data['pageItems'];
    } catch (e) {
      rethrow;
    }
  }  
  
  Future<String> getConfigContent({required String dataId, required String group, required String tenant}) async {  
    try {  
      final response = await _activeClient!.get(  
        '/nacos/v1/cs/configs',  
        queryParameters: {'dataId': dataId, 'group': group, 'tenant': tenant, 'show': 'all'},  
      );  
      // Nacos API 返回可能不一致，做兼容处理  
      if (response.data is String) return response.data;  
      return response.data['content'] ?? "";  
    } catch (e) {  
      return "";  
    }  
  }  
  
  Future<bool> publishConfig({  
    required String dataId,  
    required String group,  
    required String content,  
    required String type,  
    required String tenant,  
    String? desc, // 新增描述参数  
  }) async {  
    try {  
      final formData = FormData.fromMap({  
        'dataId': dataId, 'group': group, 'content': content, 'type': type, 'tenant': tenant,  
        if (desc != null && desc.isNotEmpty) 'desc': desc, // 添加描述参数到请求中  
      });  
      final response = await _activeClient!.post('/nacos/v1/cs/configs', data: formData);  
      return response.statusCode == 200;  
    } catch (e) {  
      debugPrint("Publish Error: $e");  
      return false;  
    }  
  }  
  
  Future<bool> deleteConfig({required String dataId, required String group, required String tenant}) async {  
    try {  
      final response = await _activeClient!.delete(  
        '/nacos/v1/cs/configs',  
        queryParameters: {'dataId': dataId, 'group': group, 'tenant': tenant},  
      );  
      return response.statusCode == 200;  
    } catch (e) {  
      return false;  
    }  
  }  
}  
