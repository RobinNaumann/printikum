import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:elbe/bit/bit/bit.dart';
import 'package:elbe/elbe.dart';
import 'package:moewe/moewe.dart';
import 'package:printikum/bit/b_config.dart';
import 'package:printikum/routes.dart';

void main() async {
  LoggerService.init(ConsoleLoggerService());
  WidgetsFlutterBinding.ensureInitialized();
  final packageInfo =
      await maybeOr(() async => await PackageInfo.fromPlatform(), null);

  // setup Moewe for crash logging
  await Moewe(
    host: "open.moewe.app",
    project: "dfdd2bd2f290bd2c",
    app: "24522f9264034f4d",
    appVersion: packageInfo?.version,
    buildNumber: int.tryParse(packageInfo?.buildNumber ?? "0"),
  ).init();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await DesktopWindow.setWindowSize(Size(430, 560));
  }

  moewe.events.appOpen();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BitProvider(
        create: (_) => ConfigBit(),
        child: ConfigBit.builder(
          onError: (_, __) => SizedBox(),
          onLoading: (_, __) => SizedBox(),
          onData: (_, conf) => ElbeApp(
              debugShowCheckedModeBanner: false,
              mode: conf.themeDark ? ColorModes.dark : ColorModes.light,
              router: router,
              theme: ThemeData.preset(color: Colors.blue)),
        ));
  }
}

String moneyStr(int? cents) {
  if (cents == null) return "? €";
  return "${cents ~/ 100}.${(cents % 100).toString().padLeft(2, "0")}€";
}

extension FilterString on String {
  String without(String chars) {
    return split("").where((c) => !chars.contains(c)).join("");
  }
}

Key anyKey(dynamic value) => Key(value.toString());

Widget loadView(_, __) => Center(child: CircularProgressIndicator.adaptive());
