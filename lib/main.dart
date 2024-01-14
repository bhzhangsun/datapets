import 'package:camera/camera.dart';
import 'package:datapets/bloc/cubit/camera_cubit.dart';
import 'package:datapets/page/home_page.dart';
import 'package:datapets/page/play_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'generated/l10n.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => CameraCubit())
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          localizationsDelegates: const [
            // 本地化的代理类
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            // 应用本地化
            L.delegate,
          ],
          supportedLocales: L.delegate.supportedLocales,
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a blue toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: "Home Page"),
        ));
  }
}
