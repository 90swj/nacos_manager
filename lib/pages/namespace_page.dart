import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import '../models/nacos_models.dart';  
import '../providers/app_provider.dart';  
import '../l10n/app_localizations.dart'; 
  
class NamespacePage extends StatelessWidget {  
  const NamespacePage({super.key});  
  
  @override  
  Widget build(BuildContext context) {  
    final state = context.watch<AppProvider>();  
    return Scaffold(  
      floatingActionButton: FloatingActionButton(  
        child: const Icon(Icons.add),  
        onPressed: () => _dialog(context, null),  
      ),  
      body: ListView.builder(  
        itemCount: state.namespaces.length,  
        itemBuilder: (ctx, i) {  
          final ns = state.namespaces[i];  
          bool isPublic = ns.namespace.isEmpty || ns.namespace == "public";  
          return ListTile(  
            title: Text(ns.namespaceShowName),  
            subtitle: Text("ID: ${isPublic ? "${AppLocalizations.of(context)!.public}" : ns.namespace}"),  
            trailing: isPublic   
              ? Chip(label: Text("${AppLocalizations.of(context)!.reserved}"))   
              : IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {  
                 bool ok = await showDialog(context: context, builder: (ctx)=>AlertDialog(  
                   title: Text("${AppLocalizations.of(context)!.confirmDeletion}?"), content: Text("${AppLocalizations.of(context)!.deleteWarning}"),  
                   actions: [  
                     TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: Text("${AppLocalizations.of(context)!.cancel}")),  
                     TextButton(onPressed: ()=>Navigator.pop(ctx, true), child: Text("${AppLocalizations.of(context)!.delete}")),  
                   ],  
                 ));  
                 if(ok) {  
                   await state.api.deleteNamespace(ns.namespace);  
                   state.refreshNamespaces();  
                 }  
              }),  
          );  
        },  
      ),  
    );  
  }  
  
  void _dialog(BuildContext context, Namespace? ns) {  
    final idCtrl = TextEditingController();  
    final nameCtrl = TextEditingController();  
    final descCtrl = TextEditingController();  
      
    showDialog(context: context, builder: (ctx) => AlertDialog(  
      title: Text(ns == null ? "${AppLocalizations.of(context)!.addNamespace}" : "${AppLocalizations.of(context)!.editNamespace}"),  
      content: Column(  
        mainAxisSize: MainAxisSize.min,  
        children: [  
          TextField(controller: idCtrl, decoration: InputDecoration(labelText: "ID")),  
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "${AppLocalizations.of(context)!.spaceName}")),  
          TextField(controller: descCtrl, decoration: InputDecoration(labelText: "${AppLocalizations.of(context)!.spaceDesc}")),  
        ],  
      ),  
      actions: [  
        TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text("${AppLocalizations.of(context)!.cancel}")),  
        TextButton(onPressed: () async {  
          await context.read<AppProvider>().api.createNamespace(idCtrl.text, nameCtrl.text, descCtrl.text);  
          context.read<AppProvider>().refreshNamespaces();  
          Navigator.pop(ctx);  
        }, child: Text("${AppLocalizations.of(context)!.save}")),  
      ],  
    ));  
  }  
}  
