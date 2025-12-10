import 'dart:convert';  
import 'package:flutter/material.dart';  
import 'package:shared_preferences/shared_preferences.dart';  
import '../models/nacos_models.dart';  
import '../services/nacos_api_service.dart';  
  
class AppProvider extends ChangeNotifier {
  final NacosApiService api = NacosApiService();
  List<NacosConnection> connections = [];
  NacosConnection? currentConnection;
  List<Namespace> namespaces = [];
    
  Namespace? _currentNamespace;
  Namespace get currentNamespace => _currentNamespace ?? Namespace(namespace: "", namespaceShowName: "public");
    
  String get currentNamespaceId => _currentNamespace?.namespace ?? "";
  
  Locale _currentLocale = const Locale('zh');
  Locale get currentLocale => _currentLocale;  
  
  AppProvider() {  
    _loadConnections();  
  }  
  
  Future<void> _loadConnections() async {  
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    String? data = prefs.getString('connections');  
    if (data != null) {  
      List list = jsonDecode(data);  
      connections = list.map((e) => NacosConnection.fromJson(e)).toList();  
      notifyListeners();  
    }  
  }  
  
  Future<void> addConnection(NacosConnection conn) async {  
    connections.add(conn);  
    await _saveConnections();  
    notifyListeners();  
  }  
  
  Future<void> deleteConnection(String id) async {  
    connections.removeWhere((e) => e.id == id);  
    await _saveConnections();  
    notifyListeners();  
  }  
  
  Future<void> _saveConnections() async {  
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    await prefs.setString('connections', jsonEncode(connections.map((e) => e.toJson()).toList()));  
  }  
  
  Future<bool> connect(NacosConnection conn) async {  
    api.setConnection(conn.url);  
    bool success = await api.login(conn.username, conn.password);  
    if (success) {  
      currentConnection = conn;  
      await refreshNamespaces();  
    }  
    return success;  
  }  
  
  Future<void> refreshNamespaces() async {  
    namespaces = await api.getNamespaces();  
    if (namespaces.isNotEmpty) {  
      // 默认保留当前选择，如果不存在则选第一个  
      if (_currentNamespace == null || !namespaces.any((n) => n.namespace == _currentNamespace!.namespace)) {  
        _currentNamespace = namespaces.first;  
      }  
    }  
    notifyListeners();  
  }  
  
  void switchNamespace(Namespace ns) {
    _currentNamespace = ns;
    notifyListeners();
  }
  
  void switchLocale(Locale locale) {
    _currentLocale = locale;
    notifyListeners();
  }  
}  
