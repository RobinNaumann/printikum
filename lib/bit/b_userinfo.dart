import 'package:elbe/elbe.dart';
import 'package:printikum/service/s_print.dart';

class UserInfoBit extends MapMsgBitControl<UserInfo> {
  static const builder = MapMsgBitBuilder<UserInfo, UserInfoBit>.make;

  UserInfoBit({required AuthUser user})
      : super.worker((_) async => PrinterService.i.info(user));
}
