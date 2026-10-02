import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/catalogo_page.dart';
import 'theme/app_theme.dart';

class MinhaEstanteApp extends StatelessWidget {
  const MinhaEstanteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minha Estante',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const CatalogoPage(),
    );
  }
}
