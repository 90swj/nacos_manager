// 连接配置模型  
class NacosConnection {  
  String id;  
  String name;  
  String url;  
  String username;  
  String password;  
  
  NacosConnection({  
    required this.id,  
    required this.name,  
    required this.url,  
    required this.username,  
    required this.password,  
  });  
  
  Map<String, dynamic> toJson() => {  
    'id': id, 'name': name, 'url': url, 'username': username, 'password': password  
  };  
  
  factory NacosConnection.fromJson(Map<String, dynamic> json) => NacosConnection(  
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),  
    name: json['name'],  
    url: json['url'],  
    username: json['username'],  
    password: json['password'],  
  );  
}  
  
// 命名空间模型  
class Namespace {  
  String namespace;  
  String namespaceShowName;  
  int configCount;  
  
  Namespace({  
    required this.namespace,  
    required this.namespaceShowName,  
    this.configCount = 0,  
  });  
  
  factory Namespace.fromJson(Map<String, dynamic> json) {  
    return Namespace(  
      namespace: json['namespace'] ?? "",  
      namespaceShowName: json['namespaceShowName'] ?? "",  
      configCount: json['configCount'] ?? 0,  
    );  
  }  
}  
  
// 配置模型  
class NacosConfig {  
  String dataId;  
  String group;  
  String? content;  
  String type;  
  String? appName;  
  String? tags;  
  String? desc; // 配置描述  
  String tenant; // 命名空间ID  
  
  NacosConfig({  
    required this.dataId,  
    required this.group,  
    this.content,  
    this.type = 'text',  
    this.appName,  
    this.tags,  
    this.desc,  
    required this.tenant,  
  });  
  
  factory NacosConfig.fromJson(Map<String, dynamic> json) {  
    return NacosConfig(  
      dataId: json['dataId'],  
      group: json['group'],  
      content: json['content'],  
      type: json['type'] ?? 'text',  
      appName: json['appName'],  
      desc: json['desc'],  
      tenant: json['tenant'] ?? '',  
    );  
  }  
}  
  
// 服务模型  
class NacosServiceInfo {  
  String name;  
  String groupName;  
  int ipCount;  
  int healthyInstanceCount;  
  
  NacosServiceInfo({  
    required this.name,  
    required this.groupName,  
    this.ipCount = 0,  
    this.healthyInstanceCount = 0,  
  });  
  
  factory NacosServiceInfo.fromJson(Map<String, dynamic> json) {  
    return NacosServiceInfo(  
      name: json['name'],  
      groupName: json['groupName'] ?? 'DEFAULT_GROUP',  
      ipCount: json['ipCount'] ?? 0,  
      healthyInstanceCount: json['healthyInstanceCount'] ?? 0,  
    );  
  }  
}  
  
// 服务实例模型  
class NacosInstance {  
  String ip;  
  int port;  
  double weight;  
  bool healthy;  
  bool enabled;  
  String clusterName;  
  String serviceName;  
  Map<String, dynamic> metadata;  
  
  NacosInstance({  
    required this.ip,  
    required this.port,  
    required this.weight,  
    required this.healthy,  
    required this.enabled,  
    required this.clusterName,  
    required this.serviceName,  
    required this.metadata,  
  });  
  
  factory NacosInstance.fromJson(Map<String, dynamic> json) {  
    return NacosInstance(  
      ip: json['ip'],  
      port: json['port'],  
      weight: (json['weight'] as num).toDouble(),  
      healthy: json['healthy'],  
      enabled: json['enabled'],  
      clusterName: json['clusterName'] ?? 'DEFAULT',  
      serviceName: json['serviceName'] ?? '',  
      metadata: json['metadata'] ?? {},  
    );  
  }  
}  
