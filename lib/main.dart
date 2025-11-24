import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tribe/core/di/service_locator.dart' as di;
import 'package:tribe/core/router/app_router.dart';
import 'package:tribe/core/theme/app_theme.dart';
import 'package:tribe/core/theme/theme_provider.dart';
import 'package:tribe/features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const TribeApp());
}

class TribeApp extends StatelessWidget {
  const TribeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<ThemeProvider>()),
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Tribe',
            theme: AppTheme.buildLightTheme(
              accentColor: themeProvider.accentColor,
              fontSizeMultiplier: themeProvider.fontSizeMultiplier,
            ),
            darkTheme: AppTheme.buildDarkTheme(
              accentColor: themeProvider.accentColor,
              fontSizeMultiplier: themeProvider.fontSizeMultiplier,
            ),
            themeMode: themeProvider.themeMode,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
