import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/strings.dart';
import 'models/document_model.dart';
import 'services/document_service.dart';
import 'services/settings_service.dart';
import 'services/template_service.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ar', null);

  await Hive.initFlutter();
  Hive.registerAdapter(DocumentModelAdapter());
  Hive.registerAdapter(DocVersionAdapter());

  final documentService = DocumentService();
  await documentService.init();

  final settingsService = SettingsService();
  await settingsService.init();

  final templateService = TemplateService();
  await templateService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: documentService),
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProvider.value(value: templateService),
      ],
      child: const WordMasterApp(),
    ),
  );
}

class WordMasterApp extends StatelessWidget {
  const WordMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: const Locale('ar'),
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      builder: (context, child) {
        // فرض اتجاه الكتابة من اليمين لليسار على كامل التطبيق.
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
