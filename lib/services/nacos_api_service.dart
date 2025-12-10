import 'dart:convert';  
import 'package:dio/dio.dart';  
import '../models/nacos_models.dart';  
  
class NacosApiService {  
  final Dio _dio = Dio();  
  String? _accessToken;  
  
  void setConnection(String url) {  
    if (url.endsWith("/")) url = url.substring(0, url.length - 1);  
    _dio.options.baseUrl = url;  
    _dio.options.connectTimeout = const Duration(seconds: 10);  
    _dio.options.receiveTimeout = const Duration(seconds: 10);  
  }  
  
  Future<bool> login(String username, String password) async {  
    try {  
      final response = await _dio.post('/nacos/v1/auth/login', queryParameters: {  
        'username': username,  
        'password': password,  
      });  
      if (response.statusCode == 200 && response.data['accessToken'] != null) {  
        _accessToken = response.data['accessToken'];  
        return true;  
      }  
    } catch (e) {  
      print("Login failed: $e");  
    }  
    return false;  
  }  
  
  Options _getOptions() {
    return Options();
  }
  
  Map<String, dynamic> _getQueryParameters() {
    return _accessToken != null ? {'accessToken': _accessToken} : {};
  }  
  
  // --- 命名空间 ---  
  Future<List<Namespace>> getNamespaces() async {  
    try {  
      final response = await _dio.get('/nacos/v1/console/namespaces', 
          options: _getOptions(), 
          queryParameters: _getQueryParameters());  
      if (response.statusCode == 200) {  
        List data = response.data['data'];  
        return data.map((e) => Namespace.fromJson(e)).toList();  
      }  
    } catch (e) { print(e); }  
    return [];  
  }  
  
  Future<bool> createNamespace(String id, String name, String desc) async {  
    try {  
      await _dio.post(
        '/nacos/v1/console/namespaces',
        data: {'customNamespaceId': id, 'namespaceName': name, 'namespaceDesc': desc},
        options: Options(contentType: Headers.formUrlEncodedContentType),
        queryParameters: _getQueryParameters()
      );
  
      return true;  
    } catch (e) { return false; }  
  }  
  
  Future<bool> deleteNamespace(String id) async {  
    try {  
      await _dio.delete(
        '/nacos/v1/console/namespaces',
        data: {'namespaceId': id},
        options: Options(contentType: Headers.formUrlEncodedContentType),
        queryParameters: _getQueryParameters()
      );
  
      return true;  
    } catch (e) { return false; }  
  }  
  
  // --- 配置 ---  
  Future<List<NacosConfig>> getConfigs(String tenant, int pageNo, int pageSize,
      {String? dataId, String? group, String? appName, String? tags, String? type, String? content}) async {
    try {
      // 当搜索内容时，使用模糊搜索，否则使用精确搜索
      String searchType = (content != null && content.isNotEmpty) ? 'blur' : 'accurate';
      
      Map<String, dynamic> params = {
        'tenant': tenant,
        'pageNo': pageNo,
        'pageSize': pageSize,
        'search': searchType,
        // 确保即使为空也要包含dataId和group参数
        'dataId': dataId ?? '',
        'group': group ?? '',
        // 确保即使为空也要包含appName和configTags参数
        'appName': appName ?? '',
        'config_tags': tags ?? ''
      };
      if (type != null && type.isNotEmpty) params['type'] = type;
      if (content != null && content.isNotEmpty) params['content'] = content;

      final response = await _dio.get('/nacos/v1/cs/configs',
          queryParameters: {...params, ..._getQueryParameters()}, options: _getOptions());
        
      if (response.statusCode == 200) {
        List list = response.data['pageItems'];
        return list.map((e) => NacosConfig.fromJson(e)).toList();
      }
    } catch (e) { print(e); }
    return [];
  }  
  
  Future<String> getConfigContent(String dataId, String group, String tenant) async {  
    try {  
      final response = await _dio.get('/nacos/v1/cs/configs',  
          queryParameters: {'dataId': dataId, 'group': group, 'tenant': tenant, ..._getQueryParameters()},
          options: _getOptions());  
      return response.data.toString();  
    } catch (e) { return ""; }  
  }  
  
  Future<bool> publishConfig(NacosConfig config) async {  
    try {  
      Map<String, dynamic> data = {  
        'dataId': config.dataId,  
        'group': config.group,  
        'content': config.content,  
        'type': config.type,  
        'tenant': config.tenant,  
      };  
      if (config.appName != null) data['appName'] = config.appName;  
      if (config.tags != null) data['config_tags'] = config.tags;  
      if (config.desc != null) data['desc'] = config.desc; // 添加描述参数  
  
      await _dio.post(  
        '/nacos/v1/cs/configs',  
        data: data,  
        options: Options(contentType: Headers.formUrlEncodedContentType),  
        queryParameters: _getQueryParameters()  
      );  
  
      return true;  
    } catch (e) { return false; }  
  }  
  
  Future<bool> deleteConfig(String dataId, String group, String tenant) async {  
    try {  
      await _dio.delete('/nacos/v1/cs/configs',  
          queryParameters: {'dataId': dataId, 'group': group, 'tenant': tenant, ..._getQueryParameters()},
          options: _getOptions());  
      return true;  
    } catch (e) { return false; }  
  }  
  
  // --- 服务 ---  
  Future<List<NacosServiceInfo>> getServices(String tenant, int pageNo, int pageSize, {String? keyword, String? groupName}) async {
    try {
      Map<String, dynamic> params = {
        'namespaceId': tenant,
        'pageNo': pageNo,
        'pageSize': pageSize,
        // 确保即使为空也要包含groupNameParam参数
        'groupNameParam': groupName ?? '',
      };
      if (keyword != null && keyword.isNotEmpty) params['serviceNameParam'] = keyword;  
  
      final response = await _dio.get('/nacos/v1/ns/service/list',  
          queryParameters: {...params, ..._getQueryParameters()}, options: _getOptions());  
        
      if (response.statusCode == 200) {  
        List list = response.data['doms'] ?? response.data['serviceList'] ?? [];  
        if (list.isNotEmpty && list.first is String) {  
          return list.map((e) => NacosServiceInfo(name: e, groupName: "DEFAULT_GROUP")).toList();  
        }  
        return list.map((e) => NacosServiceInfo.fromJson(e)).toList();  
      }  
    } catch (e) { print(e); }  
    return [];  
  }  
  
  Future<List<NacosInstance>> getInstances(String serviceName, String groupName, String tenant) async {  
    try {  
      final response = await _dio.get('/nacos/v1/ns/instance/list',  
          queryParameters: {'serviceName': '$groupName@@$serviceName', 'namespaceId': tenant, ..._getQueryParameters()},
          options: _getOptions());  
      List list = response.data['hosts'];  
      return list.map((e) => NacosInstance.fromJson(e)).toList();  
    } catch (e) { return []; }  
  }  
  
  Future<bool> updateInstance(NacosInstance instance, String namespaceId) async {  
    try {  
      Map<String, dynamic> params = {  
        'serviceName': instance.serviceName,  
        'ip': instance.ip,  
        'port': instance.port,  
        'clusterName': instance.clusterName,  
        'weight': instance.weight,  
        'enabled': instance.enabled,  
        'metadata': jsonEncode(instance.metadata),  
        'namespaceId': namespaceId  
      };  
      await _dio.put('/nacos/v1/ns/instance', 
          queryParameters: {...params, ..._getQueryParameters()}, 
          options: _getOptions());  
      return true;  
    } catch (e) { return false; }  
  }  
}  
