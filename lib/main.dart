import 'package:flutter/material.dart';  
import 'package:flutter_localizations/flutter_localizations.dart';  
import 'package:provider/provider.dart';  
import 'providers/app_provider.dart';  
import 'pages/connection_page.dart';  
import 'l10n/app_localizations.dart';
  
void main() {  
  runApp(  
    MultiProvider(  
      providers: [  
        ChangeNotifierProvider(create: (_) => AppProvider()),  
      ],  
      child: const MyApp(),  
    ),  
  );  
}  
  
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nacos Client',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: context.watch<AppProvider>().currentLocale,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: const ConnectionPage(),
    );
  }
}  
