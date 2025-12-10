import 'package:flutter/material.dart';  
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:nacos_manager/models/server_profile.dart'; // 替换为你的包名  
import 'package:nacos_manager/api/nacos_client.dart';  
import 'dashboard_page.dart';  
import '../l10n/app_localizations.dart'; 
  
class ServerManagerPage extends StatefulWidget {
  const ServerManagerPage({super.key});
  
  @override  
  _ServerManagerPageState createState() => _ServerManagerPageState();  
}  
  
class _ServerManagerPageState extends State<ServerManagerPage> {  
  List<ServerProfile> _servers = [];  
  
  @override  
  void initState() {  
    super.initState();  
    _loadServers();  
  }  
  
  // 读取本地存储的服务器列表  
  Future<void> _loadServers() async {  
    final prefs = await SharedPreferences.getInstance();  
    final String? jsonStr = prefs.getString('saved_servers');  
    if (jsonStr != null && jsonStr.isNotEmpty) {  
      setState(() => _servers = ServerProfile.decodeList(jsonStr));  
    }  
  }  
  
  // 保存列表  
  Future<void> _saveServers() async {  
    final prefs = await SharedPreferences.getInstance();  
    await prefs.setString('saved_servers', ServerProfile.encodeList(_servers));  
  }  
  
  // 弹窗：新增或编辑  
  void _showEditor({ServerProfile? profile}) {  
    final nameCtrl = TextEditingController(text: profile?.name ?? "");  
    final urlCtrl = TextEditingController(text: profile?.url ?? "http://");  
    final userCtrl = TextEditingController(text: profile?.username ?? "nacos");  
    final passCtrl = TextEditingController(text: profile?.password ?? "nacos");  
  
    showDialog(  
      context: context,  
      builder: (ctx) => AlertDialog(  
        title: Text(profile == null ? "${AppLocalizations.of(context)!.addEnvironment}" : "${AppLocalizations.of(context)!.editEnvironment}"),  
        content: SingleChildScrollView(  
          child: Column(  
            mainAxisSize: MainAxisSize.min,  
            children: [  
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "${AppLocalizations.of(context)!.remark}")),  
              TextField(controller: urlCtrl, decoration: InputDecoration(labelText: "URL (http://ip:8848)")),  
              TextField(controller: userCtrl, decoration: InputDecoration(labelText: "${AppLocalizations.of(context)!.userName}")),  
              TextField(controller: passCtrl, decoration: InputDecoration(labelText: "${AppLocalizations.of(context)!.password}"), obscureText: true),  
            ],  
          ),  
        ),  
        actions: [  
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx), 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text("${AppLocalizations.of(context)!.cancel}")
          ),
          ElevatedButton(
            onPressed: () {
              final newProfile = ServerProfile(
                id: profile?.id ?? DateTime.now().toString(),
                name: nameCtrl.text,
                url: urlCtrl.text,
                username: userCtrl.text,
                password: passCtrl.text,
              );
              setState(() {
                if (profile == null) {
                  _servers.add(newProfile);
                } else {  
                  int idx = _servers.indexWhere((e) => e.id == profile.id);  
                  _servers[idx] = newProfile;  
                }  
              });
              _saveServers();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text("${AppLocalizations.of(context)!.save}"),
          )  
        ],  
      ),  
    );  
  }  
  
  // 连接逻辑  
  void _connect(ServerProfile profile) async {  
    showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator()));  
      
    final client = NacosClient();  
    client.init(profile.url);  
    bool success = await client.login(profile.username, profile.password);  
      
    Navigator.pop(context); // 关闭 loading  
  
    if (success) {  
      Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardPage()));  
    } else {  
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${AppLocalizations.of(context)!.loginFailed}, ${AppLocalizations.of(context)!.pleaseCheckNetworkOrAccount}")));  
    }  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(title: Text("Nacos ${AppLocalizations.of(context)!.multiEnvironmentManagement}")),  
      floatingActionButton: FloatingActionButton(  
        onPressed: () => _showEditor(),  
        backgroundColor: Colors.lightBlue,  
        child: Icon(Icons.add, color: Colors.white),  
      ),
      body: _servers.isEmpty   
        ? Center(child: Text("${AppLocalizations.of(context)!.addEnvPrompt}"))  
        : ListView.builder(  
            itemCount: _servers.length,  
            itemBuilder: (ctx, i) {  
              final s = _servers[i];  
              return Dismissible(  
                key: Key(s.id),  
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: EdgeInsets.only(right: 20), child: Icon(Icons.delete, color: Colors.white)),  
                onDismissed: (_) {  
                  setState(() => _servers.removeAt(i));  
                  _saveServers();  
                },  
                child: Card(  
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),  
                  child: ListTile(  
                    leading: CircleAvatar(child: Text(s.name.isNotEmpty ? s.name.substring(0, 1) : 'N')),  
                    title: Text(s.name, style: TextStyle(fontWeight: FontWeight.bold)),  
                    subtitle: Text(s.url),  
                    trailing: IconButton(icon: Icon(Icons.edit), onPressed: () => _showEditor(profile: s)),  
                    onTap: () => _connect(s),  
                  ),  
                ),  
              );  
            },  
          ),  
    );  
  }  
}  
