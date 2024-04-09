import 'package:elbe/elbe.dart';
import 'package:moewe/moewe.dart';
import 'package:printikum/bit/b_config.dart';
import 'package:printikum/bit/b_userinfo.dart';
import 'package:printikum/main.dart';
import 'package:printikum/service/s_file.dart';
import 'package:printikum/service/s_print.dart';
import 'package:printikum/view/v_userinfo.dart';

import 'v_login.dart';
import 'v_printers.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _printerView(BuildContext context, Printer? p) {
    return p != null
        ? Card(
            heroTag: "printer-${p.id}",
            onTap: () => context.bit<ConfigBit>().setPrinter(null),
            child: Row(
                children: [
              Expanded(child: PrinterView(printer: p)),
              const Icon(Icons.x)
            ].spaced()))
        : Button.minor(
            icon: Icons.printer,
            label: "choose printer",
            onTap: () {
              context.push("/printers");
            });
  }

  Widget _fileView(BuildContext context, PrintFile? file) {
    return file != null
        ? Card(
            child: Row(
                children: [
              Icon(file.icon),
              Expanded(child: Text(file.name)),
              const Icon(Icons.x)
            ].spaced()),
            onTap: () => context.bit<ConfigBit>().setFile(null))
        : Button.minor(
            icon: Icons.file,
            label: "choose file",
            onTap: () => context.bit<ConfigBit>().chooseFile());
  }

  @override
  Widget build(BuildContext context) {
    return ConfigBit.builder(
        onData: (bit, config) => config.user == null
            ? const LoginPage()
            : BitProvider(
                key: anyKey(config.reloadCount),
                create: (_) => UserInfoBit(user: config.user!),
                child: Scaffold(
                    title: "printikum",
                    actions: [
                      IconButton.integrated(
                        icon: Icons.rotateCcw,
                        onTap: bit.incrementCounter,
                      ),
                      ThemeToggleBtn()
                    ],
                    child: Padded.all(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                AnimatedSize(
                                    duration: Duration(milliseconds: 300),
                                    child: UserInfoView()),
                                _printerView(context, config.printer),
                                _fileView(context, config.file)
                              ].spaced(),
                            ),
                          ),
                          PrintBtn()
                        ].spaced(),
                      ),
                    ))));
  }
}

class PrintBtn extends StatefulWidget {
  const PrintBtn({super.key});

  @override
  State<PrintBtn> createState() => _PrintBtnState();
}

class _PrintBtnState extends State<PrintBtn> {
  String? msg = "";

  void sendFile(PrintConfig config) async {
    try {
      setState(() => msg = null);
      await PrinterService.i
          .printFile(config.user!, config.printer!.id, config.file!.path);
      setState(() => msg = "✓ sent to printer");
      context.bit<ConfigBit>().setFile(null);
      Moewe.i.event("print_success", {"printer": config.printer!.id});
    } catch (e) {
      log.d(this, "print failed", e);
      setState(() => msg = "print failed");
      Moewe.i.event("print_failure", {"printer": config.printer!.id});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfigBit.builder(
        onData: (bit, config) => AnimatedSize(
            duration: Duration(milliseconds: 300),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Button.major(
                      icon: Icons.printer,
                      label: msg == null ? "sending..." : "print",
                      onTap: msg == null ||
                              config.printer == null ||
                              config.file == null
                          ? null
                          : () => sendFile(config)),
                  if (msg?.isNotEmpty ?? false)
                    Padded.only(
                        top: 1,
                        child: Text.bodyS(msg!,
                            variant: TypeVariants.bold,
                            textAlign: TextAlign.center))
                ])));
  }
}

class ThemeToggleBtn extends StatelessWidget {
  const ThemeToggleBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfigBit.builder(
        onData: (bit, config) => IconButton.integrated(
            onTap: bit.toggleTheme,
            icon: config.themeDark ? Icons.sun : Icons.moon));
  }
}
