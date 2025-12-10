import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import '../l10n/app_localizations.dart';  
import '../models/nacos_models.dart';  
import '../providers/app_provider.dart';  
import 'config_list_page.dart';  
import 'service_list_page.dart';  
import 'namespace_page.dart';
  
class DashboardPage extends StatefulWidget {  
  const DashboardPage({super.key});  
  
  @override  
  State<DashboardPage> createState() => _DashboardPageState();  
}  
  
class _DashboardPageState extends State<DashboardPage> {  
  int _selectedIndex = 0;  
  final List<Widget> _pages = [const ConfigListPage(), const ServiceListPage(), const NamespacePage()];  
  
  @override  
  Widget build(BuildContext context) {  
    final state = context.watch<AppProvider>();  
    return Scaffold(  
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? AppLocalizations.of(context)!.configManagement : (_selectedIndex == 1 ? AppLocalizations.of(context)!.serviceDiscovery : AppLocalizations.of(context)!.namespace)),
        actions: [
          if (_selectedIndex != 2)
            PopupMenuButton<Namespace>(
              initialValue: state.currentNamespace,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Text(state.currentNamespace.namespaceShowName.isEmpty ? AppLocalizations.of(context)!.public : state.currentNamespace.namespaceShowName, style: const TextStyle(fontSize: 16)),
                  const Icon(Icons.arrow_drop_down)
                ]),
              ),
              onSelected: (Namespace item) => context.read<AppProvider>().switchNamespace(item),
              itemBuilder: (BuildContext context) {
                return state.namespaces.map((Namespace choice) {
                  return PopupMenuItem<Namespace>(
                    value: choice,
                    child: Text(choice.namespaceShowName.isEmpty ? AppLocalizations.of(context)!.public : choice.namespaceShowName),
                  );
                }).toList();
              },
            ),
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
        ],
      ),  
      body: IndexedStack(index: _selectedIndex, children: _pages),  
      bottomNavigationBar: NavigationBar(  
        selectedIndex: _selectedIndex,  
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),  
        destinations: [
          NavigationDestination(icon: const Icon(Icons.description_outlined), selectedIcon: const Icon(Icons.description), label: AppLocalizations.of(context)!.config),
          NavigationDestination(icon: const Icon(Icons.dns_outlined), selectedIcon: const Icon(Icons.dns), label: AppLocalizations.of(context)!.service),
          NavigationDestination(icon: const Icon(Icons.layers_outlined), selectedIcon: const Icon(Icons.layers), label: AppLocalizations.of(context)!.space),
        ],  
      ),  
    );  
  }  
}  
