import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import 'package:fluttertoast/fluttertoast.dart';  
import '../l10n/app_localizations.dart';  
import '../models/nacos_models.dart';  
import '../providers/app_provider.dart';  
import 'dashboard_page.dart';
  
class ConnectionPage extends StatelessWidget {  
  const ConnectionPage({super.key});  
  
  @override  
  Widget build(BuildContext context) {  
    final state = context.watch<AppProvider>();  
  
    return Scaffold(  
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle), actions: [
        PopupMenuButton<Locale>(
          initialValue: state.currentLocale,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(children: [
              Icon(Icons.language),
              Icon(Icons.arrow_drop_down)
            ]),
          ),
          onSelected: (Locale item) => context.read<AppProvider>().switchLocale(item),
          itemBuilder: (BuildContext context) {
              return const [
                PopupMenuItem<Locale>(
                  value: Locale('zh'),
                  child: Text('中文'),
                ),
                PopupMenuItem<Locale>(
                  value: Locale('en'),
                  child: Text('English'),
                ),
              ];
            },
        ),
      ],),  
      floatingActionButton: FloatingActionButton(  
        child: const Icon(Icons.add),  
        onPressed: () => _showAddDialog(context),  
      ),  
      body: state.connections.isEmpty   
        ? Center(child: Text(AppLocalizations.of(context)!.noConnectionAvailable))  
        : ListView.builder(  
        itemCount: state.connections.length,  
        itemBuilder: (ctx, index) {  
          final conn = state.connections[index];  
          return Dismissible(  
            key: Key(conn.id),  
            background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),  
            direction: DismissDirection.endToStart,  
            onDismissed: (_) => context.read<AppProvider>().deleteConnection(conn.id),  
            child: Card(  
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),  
              child: ListTile(  
                title: Text(conn.name, style: const TextStyle(fontWeight: FontWeight.bold)),  
                subtitle: Text(conn.url),  
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),  
                onTap: () async {  
                  showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));  
                  bool success = await state.connect(conn);  
                  Navigator.pop(context);  
                  if (success) {  
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardPage()));  
                  } else {  
                    Fluttertoast.showToast(msg: AppLocalizations.of(context)!.loginFailed);  
                  }  
                },  
              ),  
            ),  
          );  
        },  
      ),  
    );  
  }  
  
  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController(text: "http://");
    final userCtrl = TextEditingController(text: "nacos");
    final passCtrl = TextEditingController(text: "nacos");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.addConnection),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.connectionName)),
              TextField(controller: urlCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.connectionUrl)),
              TextField(controller: userCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.userName)),
              TextField(controller: passCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.password), obscureText: true)
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(ctx)!.cancel)),
          TextButton(
            onPressed: () {
              if(nameCtrl.text.isEmpty || urlCtrl.text.isEmpty) return;
              Provider.of<AppProvider>(ctx, listen: false).addConnection(NacosConnection(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text, url: urlCtrl.text, username: userCtrl.text, password: passCtrl.text
              ));
              Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(ctx)!.save),
          ),
        ],
      ),
    );
  }  
}  
