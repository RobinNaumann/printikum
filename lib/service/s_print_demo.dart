import 'package:printikum/service/s_print.dart';

class DemoPrintService extends PrinterService {
  int printed = 0;

  @override
  Future<UserInfo> info(AuthUser user) async {
    return UserInfo(
      balance: 1000 - printed * 10,
      printed: printed,
    );
  }

  @override
  Future<List<Printer>> list(AuthUser user) async {
    return [
      Printer(
        id: "A1_fa",
        accepting: true,
        entries: 0,
        price: 10,
      ),
      Printer(
        id: "A1_sw",
        accepting: true,
        entries: 0,
        price: 5,
      ),
      Printer(
        id: "A2_fa",
        accepting: false,
        entries: 0,
        price: 10,
      ),
      Printer(
        id: "A2_sw",
        accepting: true,
        entries: 0,
        price: 5,
      ),
    ];
  }

  @override
  Future<void> login(AuthUser user) async {
    await Future.delayed(Duration(seconds: 1));
    if (user.username.toLowerCase() != "demo" || user.password != "Hamburg24") {
      throw Exception("login failed");
    }
  }

  @override
  Future<void> printFile(AuthUser user, String printer, String path) async {
    await Future.delayed(Duration(seconds: 1));
    printed++;
  }
}
