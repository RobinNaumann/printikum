import 'package:elbe/elbe.dart';
import 'package:elbe/util/m_data.dart';
import 'package:flutter/scheduler.dart';
import 'package:printikum/service/s_file.dart';
import 'package:printikum/service/s_print.dart';

class PrintConfig extends DataModel {
  final bool themeDark;
  final AuthUser? user;
  final Printer? printer;
  final PrintFile? file;
  final int reloadCount;

  PrintConfig(
      {this.user,
      this.printer,
      this.file,
      bool? themeDark,
      this.reloadCount = 0})
      : this.themeDark = themeDark ??
            SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark;

  @override
  get map => {
        'user': user,
        'printer': printer,
        'file': file,
        'themeDark': themeDark,
        'reloadCount': reloadCount
      };

  PrintConfig copyWith(
          {AuthUser? Function()? user,
          Printer? Function()? printer,
          PrintFile? Function()? file,
          bool? themeDark,
          int? reloadCount}) =>
      PrintConfig(
          user: user != null ? user() : this.user,
          printer: printer != null ? printer() : this.printer,
          file: file != null ? file() : this.file,
          themeDark: themeDark ?? this.themeDark,
          reloadCount: reloadCount ?? this.reloadCount);
}

class ConfigBit extends MapMsgBitControl<PrintConfig> {
  static const builder = MapMsgBitBuilder<PrintConfig, ConfigBit>.make;

  ConfigBit({String? picked}) : super.worker((_) => PrintConfig());

  setUser(AuthUser? user) =>
      state.whenData((data) => emit(data.copyWith(user: () => user)));

  chooseFile() => state.whenData((data) async {
        final file = await FileService.i.userPick();
        if (file != null) emit(data.copyWith(file: () => file));
      });

  incrementCounter() => state
      .whenData((d) => emit(d.copyWith(reloadCount: (d.reloadCount + 1) % 10)));

  setFile(PrintFile? file) =>
      state.whenData((data) => emit(data.copyWith(file: () => file)));

  setPrinter(Printer? p) =>
      state.whenData((data) => emit(data.copyWith(printer: () => p)));

  toggleTheme() =>
      state.whenData((d) => emit(d.copyWith(themeDark: !d.themeDark)));
}
