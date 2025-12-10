import 'dart:convert';

class ServerProfile {  
  final String id;  
  String name;  
  String url;  
  String username;  
  String password;  

  ServerProfile({  
    required this.id,  
    required this.name,  
    required this.url,  
    required this.username,  
    required this.password,  
  });  

  Map<String, dynamic> toJson() => {  
        'id': id,  
        'name': name,  
        'url': url,  
        'username': username,  
        'password': password,  
      };  

  factory ServerProfile.fromJson(Map<String, dynamic> json) {  
    return ServerProfile(  
      id: json['id'],  
      name: json['name'],  
      url: json['url'],  
      username: json['username'],  
      password: json['password'],  
    );  
  }  
  
  // 静态方法：从JSON字符串解码为ServerProfile列表
  static List<ServerProfile> decodeList(String jsonStr) {
    List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((json) => ServerProfile.fromJson(json)).toList();
  }
  
  // 静态方法：将ServerProfile列表编码为JSON字符串
  static String encodeList(List<ServerProfile> profiles) {
    List<Map<String, dynamic>> jsonList = profiles.map((profile) => profile.toJson()).toList();
    return jsonEncode(jsonList);
  }
}  
