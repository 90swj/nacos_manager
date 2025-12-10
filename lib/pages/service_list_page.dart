import 'dart:convert';  
import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import 'package:fluttertoast/fluttertoast.dart';  
import '../l10n/app_localizations.dart';  
import '../models/nacos_models.dart';  
import '../providers/app_provider.dart';
  
class ServiceListPage extends StatefulWidget {  
  const ServiceListPage({super.key});  
  @override  
  State<ServiceListPage> createState() => _ServiceListPageState();  
}  
  
class _ServiceListPageState extends State<ServiceListPage> {
  List<NacosServiceInfo> services = [];
  bool loading = false;
  String? searchKeyword;
  String? searchGroup;
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  void _search() {
    final keyword = _keywordController.text.trim();
    final group = _groupController.text.trim();
    _load(kw: keyword.isEmpty ? null : keyword, group: group.isEmpty ? null : group);
  }

  Future<void> _load({String? kw, String? group}) async {
    setState(() => loading = true);
    searchKeyword = kw;
    searchGroup = group;
    _keywordController.text = kw ?? '';
    _groupController.text = group ?? '';
    final state = context.read<AppProvider>();
    services = await state.api.getServices(
      state.currentNamespaceId, 
      1, 
      200, 
      keyword: kw,
      groupName: group
    );
    setState(() => loading = false);
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      body: Column(  
        children: [  
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.searchServiceName, 
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (v) => _search(),
                  controller: _keywordController,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.searchGroup, 
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (v) => _search(),
                  controller: _groupController,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                  label: Text(AppLocalizations.of(context)!.search),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),  
          Expanded(  
            child: loading ? const Center(child: CircularProgressIndicator()) : ListView.separated(  
              separatorBuilder: (_,__) => const Divider(height: 1),  
              itemCount: services.length,  
              itemBuilder: (ctx, i) {  
                final s = services[i];  
                return ListTile(  
                  leading: const Icon(Icons.dns, color: Colors.blue),  
                  title: Text(s.name),  
                  subtitle: Text("${AppLocalizations.of(context)!.group}: ${s.groupName} | ${AppLocalizations.of(context)!.instances}: ${s.ipCount}"),  
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),  
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailPage(service: s))),  
                );  
              },  
            ),  
          )  
        ],  
      ),  
    );  
  }  
}  
  
class ServiceDetailPage extends StatefulWidget {  
  final NacosServiceInfo service;  
  const ServiceDetailPage({super.key, required this.service});  
  
  @override  
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();  
}  
  
class _ServiceDetailPageState extends State<ServiceDetailPage> {  
  List<NacosInstance> instances = [];  
  bool loading = true;  
  
  @override  
  void initState() {  
    super.initState();  
    _load();  
  }  
  
  Future<void> _load() async {  
    final state = context.read<AppProvider>();  
    instances = await state.api.getInstances(widget.service.name, widget.service.groupName, state.currentNamespaceId);  
    setState(() => loading = false);  
  }  
  
  void _editInstance(NacosInstance inst) {  
    // 元数据格式化  
    String metaStr = "{}";  
    try { metaStr = jsonEncode(inst.metadata); } catch(_){}  
    final metaCtrl = TextEditingController(text: metaStr);  
      
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.edit),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.ipPortNotEditable, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 5),
              TextField(controller: TextEditingController(text: inst.ip), decoration: InputDecoration(labelText: AppLocalizations.of(context)!.ip, border: const OutlineInputBorder()), enabled: false),
              const SizedBox(height: 10),
              TextField(controller: TextEditingController(text: inst.port.toString()), decoration: InputDecoration(labelText: AppLocalizations.of(context)!.port, border: const OutlineInputBorder()), enabled: false),
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.metadata),
              TextField(controller: metaCtrl, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(onPressed: () async {  
            try {  
              Map<String, dynamic> meta = jsonDecode(metaCtrl.text);  
              inst.metadata = meta;  
              bool ok = await context.read<AppProvider>().api.updateInstance(inst, context.read<AppProvider>().currentNamespaceId);  
              if(ok) {
                _load();
                Navigator.pop(ctx);
                Fluttertoast.showToast(msg: AppLocalizations.of(context)!.updateSuccess);
              } else {
                Fluttertoast.showToast(msg: AppLocalizations.of(context)!.updateFailed);
              }
            } catch(e) {
              Fluttertoast.showToast(msg: AppLocalizations.of(context)!.jsonFormatError);
            }
          }, child: Text(AppLocalizations.of(context)!.save)),  
        ],  
      );  
    });  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(title: Text(widget.service.name)),  
      body: loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(  
        itemCount: instances.length,  
        itemBuilder: (ctx, i) {  
          final inst = instances[i];  
          return Card(  
            child: ListTile(  
              leading: Column(  
                mainAxisAlignment: MainAxisAlignment.center,  
                children: [  
                  Icon(Icons.circle, color: inst.healthy ? Colors.green : Colors.red, size: 14),  
                  Text(inst.healthy ? AppLocalizations.of(context)!.healthy : AppLocalizations.of(context)!.unhealthy, style: const TextStyle(fontSize: 10))  
                ],  
              ),  
              title: Text("${inst.ip}:${inst.port}"),  
              subtitle: Text("${AppLocalizations.of(context)!.cluster}: ${inst.clusterName}\n${AppLocalizations.of(context)!.weight}: ${inst.weight}"),  
              trailing: Row(  
                mainAxisSize: MainAxisSize.min,  
                children: [  
                  Switch(value: inst.enabled, onChanged: (val) async {  
                    inst.enabled = val;  
                    await context.read<AppProvider>().api.updateInstance(inst, context.read<AppProvider>().currentNamespaceId);  
                    _load();  
                  }),  
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _editInstance(inst)),  
                ],  
              ),  
            ),  
          );  
        },  
      ),  
    );  
  }  
}  
