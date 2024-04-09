import 'package:elbe/elbe.dart';
import 'package:printikum/bit/b_config.dart';
import 'package:printikum/bit/b_printers.dart';
import 'package:printikum/main.dart';
import 'package:printikum/service/s_print.dart';

class PrintersPage extends StatelessWidget {
  const PrintersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      actions: [],
      leadingIcon: LeadingIcon.close(),
      title: "printers",
      child: ConfigBit.builder(
          onData: (_, c) => BitProvider(
              create: (_) => PrinterListBit(user: c.user!),
              child: Padded.all(child: const _ListView()))),
    );
  }
}

class _ListView extends StatefulWidget {
  const _ListView({super.key});

  @override
  State<_ListView> createState() => _ListViewState();
}

class _ListViewState extends State<_ListView> {
  bool? colored;
  String? house;

  Widget colorSelect() {
    return Row(children: [
      for (final c in [true, false])
        IconButton(
          constraints: RemConstraints(minWidth: 3, minHeight: 3),
          icon: c ? Icons.palette : Icons.droplet,
          onTap: () => setState(() => colored = colored == c ? null : c),
          style: colored == c ? ColorStyles.minorAccent : ColorStyles.plain,
        ),
    ]);
  }

  Widget houseSelect(List<Printer> printers) {
    final houses =
        printers.map((p) => p.richData?.house).whereType<String>().toSet();
    return Row(
      children: [
        for (final h in houses)
          Button(
            constraints: RemConstraints(minWidth: 3, minHeight: 3),
            label: h.toUpperCase(),
            onTap: () {
              setState(() => house = house == h ? null : h);
            },
            style: house == h ? ColorStyles.minorAccent : ColorStyles.plain,
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfigBit.builder(
        onData: (configBit, config) => PrinterListBit.builder(
            onLoading: loadView,
            onData: (bit, data) => Column(
                    children: [
                  if (data.isNotEmpty)
                    SingleChildScrollView(
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children:
                                [colorSelect(), houseSelect(data)].spaced())),
                  Expanded(
                      child: _PrinterList(
                          printers: data.where((p) {
                            if (colored != null && p.richData?.color != colored)
                              return false;
                            if (house != null && p.richData?.house != house)
                              return false;
                            return true;
                          }).toList(),
                          onSelect: (p) {
                            configBit.setPrinter(p);
                            Navigator.of(context).pop();
                          },
                          selected: config.printer))
                ].spaced())));
  }
}

class _PrinterList extends StatelessWidget {
  final List<Printer> printers;
  final Function(Printer p) onSelect;
  final Printer? selected;
  const _PrinterList(
      {super.key,
      required this.printers,
      required this.onSelect,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return printers.isEmpty
        ? Center(child: Text("No printers\nfound", textAlign: TextAlign.center))
        : ListView.builder(
            itemCount: printers.length,
            itemBuilder: (context, index) {
              final printer = printers[index];
              return Padded.only(
                bottom: 1,
                child: Card(
                    heroTag: "printer-${printer.id}",
                    onTap: () {
                      if (!printer.accepting) return;
                      onSelect(printer);
                    },
                    style: selected?.id == printer.id
                        ? ColorStyles.minorAccent
                        : ColorStyles.plain,
                    state: printer.accepting ? null : ColorStates.disabled,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: PrinterView(printer: printer)),
                          Icon(
                            selected?.id == printer.id
                                ? Icons.checkCircle
                                : Icons.circle,
                          )
                        ].spaced(amount: 1.5))),
              );
            },
          );
  }
}

class PrinterView extends StatelessWidget {
  final Printer printer;
  const PrinterView({super.key, required this.printer});

  Widget priceView(int price) {
    return Text.bodyS("$price ct. / page");
  }

  Widget acceptingChip(bool accepting, int count) {
    return Box(
        style: accepting
            ? ColorStyles.minorAlertSuccess
            : ColorStyles.minorAlertInfo,
        border: Border(borderRadius: BorderRadius.circular(10)),
        padding: RemInsets.symmetric(horizontal: 0.5, vertical: 0.3),
        child: Text.bodyS(accepting ? 'running ($count)' : 'not available'));
  }

  Widget title(Printer d) {
    final data = d.richData;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (data != null)
        Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Box.plain(
                  decoration: BoxDecoration(color: Colors.transparent),
                  constraints: RemConstraints(minWidth: 4),
                  child: Row(
                      children: [
                    Text(data.house.toUpperCase(), variant: TypeVariants.bold),
                    Text(data.room.toUpperCase())
                  ].spaced(amount: 0.3))),
              data.color != null
                  ? Tooltip(
                      message: data.color! ? 'Color printer' : 'B/W printer',
                      child: Icon(data.color! ? Icons.palette : Icons.droplet,
                          style: TypeStyles.bodyS))
                  : Spaced.horizontal(1.4)
            ].spaced()),
      Text.bodyS(d.id), //, variant: TypeVariants.bold),
      Padded.only(top: 0.5, child: priceView(d.price))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      spacing: context.rem(1),
      runSpacing: context.rem(1),
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title(printer),
        acceptingChip(printer.accepting, printer.entries),
      ].spaced(),
    );
  }
}
