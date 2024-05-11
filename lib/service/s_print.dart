import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:elbe/elbe.dart';
import 'package:elbe/util/m_data.dart';
import 'package:html/parser.dart' as html;
import 'package:moewe/moewe.dart';
import 'package:printikum/config.dart';
import 'package:printikum/main.dart';

/*extension SimpleElement on Element {
  String? get text => innerHtml?.trim();
  String? get val => text?.toLowerCase();
  int? get valInt => int.tryParse(val ?? '');
}*/

extension MaybeList<T> on List<T> {
  T? maybe(int id) => id < length ? this[id] : null;
}

class UserInfo extends DataModel {
  final int? balance;
  final int? printed;

  UserInfo({this.balance, this.printed});

  @override
  get map => {'balance': balance, 'printed': printed};
}

class AuthUser extends DataModel {
  final String username;
  final String password;

  AuthUser(this.username, this.password);

  @override
  get map => {'username': username, 'password': password};
}

class Printer extends DataModel {
  final String id;
  final bool accepting;
  final int? entries;
  // the price per page in cents
  final int? price;

  RichPrinterData? get richData => RichPrinterData.tryParse(id);

  Printer({
    required this.id,
    required this.accepting,
    required this.entries,
    required this.price,
  });

  @override
  get map => {
        'id': id,
        'accepting': accepting,
        'entries': entries,
        'price': price,
      };
}

class RichPrinterData extends DataModel {
  final String house;
  final String room;
  final bool? color;

  RichPrinterData(
    this.house,
    this.room,
    this.color,
  );

  @override
  get map => {'house': house, 'room': room, 'color': color};

  static tryParse(String id) {
    final parts = id.split('_');
    if (parts.length != 2 ||
        !parts.first.startsWith(RegExp(r"[a-zA-Z][0-9]"))) {
      return null;
    }

    return RichPrinterData(
        parts.first.substring(0, 1),
        parts[0].substring(1),
        parts[1].startsWith("fa")
            ? true
            : (parts[1].startsWith("sw") ? false : null));
  }
}

class PrinterService {
  static PrinterService i = PrinterService._();
  PrinterService._();

  Future<void> login(AuthUser user) async {
    const msg = "printikum";
    final p = await _exec(user, 'echo $msg');
    if (p != msg) throw Exception("login failed");
    moewe.events.login(method: "informatik");
  }

  Future<void> printFile(AuthUser user, String printer, String path) async {
    final client = SSHClient(
        await SSHSocket.connect(appConfig.server.host, appConfig.server.port),
        username: user.username,
        onPasswordRequest: () => user.password);

    final session = await client.execute('cat | lpr -P$printer');
    await session.stdin.addStream(File(path).openRead().cast());
    await session.stdin.close();
    client.close();
  }

  Future<UserInfo> info(AuthUser user) async {
    final doc = html.parse(await _curl(user, appConfig.dataSources.userInfo));

    final elements = doc.body?.querySelectorAll("font");
    final elementRest = (elements ?? []).firstWhereOrNull(
        (element) => element.text.toLowerCase().contains("restguthaben"));
    final balStr = elementRest?.querySelector("b")?.text.without(" €.");

    final printedRow = doc.body
        ?.querySelector("#content")
        ?.querySelector("table")
        ?.querySelectorAll("tr")
        .lastOrNull;

    return UserInfo(
        balance: balStr != null ? int.tryParse(balStr) : null,
        printed: printedRow != null
            ? int.tryParse(printedRow.querySelectorAll("td")[1].text)
            : null);
  }

  Future<List<Printer>> list(AuthUser user) async {
    final doc = html.parse(await _curl(user, appConfig.dataSources.printers));
    final rows = doc.body
            ?.querySelector("#content")
            ?.querySelector("table")
            ?.querySelectorAll("tr") ??
        [];

    final printers = rows.skip(1).map((e) {
      final cols = e.querySelectorAll("td");
      try {
        return Printer(
            id: cols[0].innerHtml.trim(),
            accepting: cols[1].innerHtml.toLowerCase().trim() == "enabled" &&
                cols[2].innerHtml.toLowerCase().trim() == "enabled",
            entries: int.tryParse(cols.maybe(3)?.innerHtml.trim() ?? "/"),
            price: int.tryParse(cols
                    .maybe(4)
                    ?.innerHtml
                    .replaceAll("€", "")
                    .replaceAll(".", "")
                    .trim() ??
                "/"));
      } catch (_) {
        log.d(this, "could not parse a printer");
        return null;
      }
    });

    return printers.whereNotNull().toList();
  }

  Future<String> _exec(AuthUser user, String cmd) async {
    final client = SSHClient(
        await SSHSocket.connect(appConfig.server.host, appConfig.server.port),
        username: user.username,
        onPasswordRequest: () => user.password);

    final d = await client.run(cmd);
    client.close();
    return utf8.decode(d).trim();
  }

  Future<String> _curl(AuthUser user, String url) =>
      _exec(user, 'curl -u ${user.username}:${user.password} $url');
}



// cat beispiel.pdf | ssh 1steenfa@rzssh1.informatik.uni-hamburg.de lpr -Pg235_hp