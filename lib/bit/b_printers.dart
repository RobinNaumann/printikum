import 'package:elbe/elbe.dart';
import 'package:moewe/moewe.dart';
import 'package:printikum/service/s_print.dart';

class PrinterListBit extends MapMsgBitControl<List<Printer>> {
  static const builder = MapMsgBitBuilder<List<Printer>, PrinterListBit>.make;

  PrinterListBit({required AuthUser user})
      : super.worker((_) {
          Moewe.i.event("list_printers");
          return PrinterService.i.list(user);
        });
}
