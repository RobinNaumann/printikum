import 'package:elbe/elbe.dart';
import 'package:printikum/bit/b_config.dart';
import 'package:printikum/bit/b_userinfo.dart';
import 'package:printikum/main.dart';

class UserInfoView extends StatelessWidget {
  final String username;
  const UserInfoView({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    print(key);
    return ConfigBit.builder(onData: (bit, config) {
      return Row(
          children: [
        Button.integrated(
            label: config.user?.username ?? "login",
            icon: Icons.x,
            onTap: () => bit.setUser(null)),
        const Expanded(child: BalanceView()),
      ].spaced());
    });
  }
}

class BalanceView extends StatelessWidget {
  const BalanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const RemConstraints(minHeight: 3).toPixel(context),
      child: UserInfoBit.builder(
          onLoading: (_, __) =>
              const Center(child: CircularProgressIndicator.adaptive()),
          onError: (bit, error) =>
              const Text("could not\nload balance", textAlign: TextAlign.end),
          onData: (bit, data) => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (data.printed != null)
                    Text("${data.printed} pages printed"),
                  Text(
                      data.balance != null
                          ? "${moneyStr(data.balance)} left"
                          : "?",
                      variant: TypeVariants.bold),
                ],
              )),
    );
  }
}
