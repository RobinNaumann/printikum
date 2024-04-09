import 'package:elbe/elbe.dart';
import 'package:printikum/view/v_home.dart';
import 'package:printikum/view/v_printers.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/printers',
      builder: (context, state) {
        return const PrintersPage();
      },
    ),
  ],
);
