import 'package:elbe/elbe.dart';
import 'package:flutter/material.dart' as m;
import 'package:moewe/moewe.dart';
import 'package:printikum/bit/b_config.dart';
import 'package:printikum/config.dart';
import 'package:printikum/service/s_print.dart';
import 'package:printikum/view/v_home.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String inUsername = "";
  String inPassword = "";

  String state = "initial";

  void login(BuildContext c) async {
    try {
      setState(() => state = "loading");
      final auth = AuthUser(inUsername, inPassword);
      await PrinterService.i.login(auth);
      log.d(this, "logged in");
      c.bit<ConfigBit>().setUser(auth);
    } catch (e) {
      log.d(this, "login failed", e);
      setState(() => state = "error");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _NewVersionBar(),
        Expanded(
          child: Scaffold(
            actions: [ThemeToggleBtn()],
            title: "printikum",
            children: [
              Text.bodyS(
                "an open source, no setup tool to print files at the computer science campus at the University of Hamburg",
              ),
              TextFormField(
                onChanged: (v) => setState(() => inUsername = v),
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: "username (3mustermann)",
                    border: InputBorder.none,
                    hintMaxLines: 1),
              ),
              TextFormField(
                onChanged: (v) => setState(() => inPassword = v),
                autofocus: true,
                obscureText: true,
                decoration: const InputDecoration(
                    hintText: "password",
                    border: InputBorder.none,
                    hintMaxLines: 1),
              ),
              Button.major(
                  label: state == "loading" ? "loading..." : "login",
                  onTap: state == "loading" ||
                          inUsername.isEmpty ||
                          inPassword.isEmpty
                      ? null
                      : () => login(context)),
              Text.bodyS(
                "your credentials are only sent to the servers\nmanaged by the university",
                textAlign: TextAlign.center,
              ),
              if (state == "error")
                Card(
                    margin: const RemInsets(top: 1),
                    style: ColorStyles.minorAlertError,
                    child: Row(
                        children: [
                      const Icon(Icons.alertTriangle),
                      Text.bodyS("login failed")
                    ].spaced())),
              Spaced(),
              AboutSection()
            ].spaced(),
          ),
        ),
      ],
    );
  }
}

class _NewVersionBar extends StatefulWidget {
  const _NewVersionBar({super.key});

  @override
  State<_NewVersionBar> createState() => _NewVersionBarState();
}

class _NewVersionBarState extends State<_NewVersionBar> {
  bool isOpen = false;

  @override
  void initState() {
    super.initState();

    if (!(moewe.config.isLatestVersion() ?? true)) {
      setState(() => isOpen = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return !isOpen
        ? Spaced.zero
        : m.Material(
            color: Colors.transparent,
            child: Card(
                onTap: () {
                  launchUrlString(appConfig.about.homepage);
                },
                border: Border.noneRect,
                style: ColorStyles.majorAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.externalLink),
                    Expanded(child: Text("a new version is available")),
                    IconButton.integrated(
                        icon: Icons.x,
                        onTap: () => setState(() => isOpen = false))
                  ].spaced(),
                )));
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
      Row(children: [
        Expanded(
            child: Button.action(
                icon: Icons.globe,
                label: "about",
                onTap: () {
                  launchUrlString(appConfig.about.homepage);
                })),
        Expanded(
            child: Button.action(
                icon: Icons.github,
                label: "source",
                onTap: () {
                  launchUrlString(appConfig.about.source);
                })),
      ]),
      Text.bodyS("v${moewe.appVersion} by ${appConfig.about.author}",
          color: Colors.grey)
    ].spaced());
  }
}
