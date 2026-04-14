import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_strings.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';
import 'package:programming_learn_app/core/router/app_router.dart';
import 'package:programming_learn_app/core/theme/app_theme.dart';
import 'package:programming_learn_app/ui/components/offline_banner.dart';

class CodeQuestApp extends StatefulWidget {
  const CodeQuestApp({super.key});

  @override
  State<CodeQuestApp> createState() => _CodeQuestAppState();
}

class _CodeQuestAppState extends State<CodeQuestApp> {
  bool _isOffline = false;
  late final GoRouter _router;
  late final StreamSubscription<dynamic> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.create();
    _primeConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateOfflineState);
  }

  Future<void> _primeConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateOfflineState(result);
  }

  void _updateOfflineState(dynamic result) {
    bool offline = false;

    if (result is ConnectivityResult) {
      offline = result == ConnectivityResult.none;
    } else if (result is List<ConnectivityResult>) {
      offline = result.isEmpty || result.every((entry) => entry == ConnectivityResult.none);
    }

    if (!mounted || offline == _isOffline) {
      return;
    }

    setState(() {
      _isOffline = offline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(child: child ?? const SizedBox.shrink()),
            AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              offset: _isOffline ? Offset.zero : const Offset(0, -1),
              child: const OfflineBanner(),
            ),
          ],
        );
      },
      theme: appTheme.copyWith(textTheme: AppTextStyles.textTheme(Theme.of(context).textTheme)),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
