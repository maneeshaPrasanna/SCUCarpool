import 'package:santa_clara/pages/home/home_page.dart';
import 'package:santa_clara/pages/my_ride_screen.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:santa_clara/pages/settings/setting_page.dart';

class MyRoutes {
  static MyRoute home = MyRoute(name: 'home', path: '/');
  static MyRoute signIn = MyRoute(name: 'signIn', path: '/signIn');
  static MyRoute verifyEmail =
      MyRoute(name: 'verifyEmail', path: '/verifyEmail');
  static MyRoute offerRide = MyRoute(name: 'offerRide', path: '/offerRide');
  static MyRoute planYourRide =
      MyRoute(name: 'planYourRide', path: '/planYourRide');
  static MyRoute rideScreen = MyRoute(name: 'rideScreen', path: '/rideScreen');
  static MyRoute rideDetails =
      MyRoute(name: 'rideDetails', path: '/rideDetails');
}

class IndexedRoutes {
  final List<MyRoute> routes = [
    MyRoute(
      name: 'carpool',
      path: 'carpool',
      label: 'Home',
      icon: Icons.home,
      child: const HomePage(),
    ),
    MyRoute(
        name: 'activity',
        path: 'activity',
        label: 'Activity',
        icon: Icons.history,
        child: const MyRideScreen()),
    MyRoute(
        name: 'settings',
        path: 'settings',
        label: 'Settings',
        icon: Icons.settings,
        child: const SettingPage(title: "Settings")),
  ];

  int getIndex(String path) {
    return routes.indexWhere((route) {
      return path.contains(route.path);
    });
  }

  String getName(int index) {
    return routes[index].name;
  }
}

class MyRoute {
  final String name;
  final String path;
  String? label;
  IconData? icon;
  Widget? child;

  MyRoute(
      {required this.name,
      required this.path,
      this.icon,
      this.child,
      this.label});
}

class MyNavObserver extends NavigatorObserver {
  MyNavObserver() {
    log.onRecord.listen((e) => debugPrint('$e'));
  }

  final log = Logger('MyNavObserver');

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      log.info('didPush: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      log.info('didPop: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      log.info('didRemove: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      log.info('didReplace: new= ${newRoute?.str}, old= ${oldRoute?.str}');

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) =>
      log.info('didStartUserGesture: ${route.str}, '
          'previousRoute= ${previousRoute?.str}');

  @override
  void didStopUserGesture() => log.info('didStopUserGesture');
}

extension on Route<dynamic> {
  String get str => 'route(${settings.name}: ${settings.arguments})';
}
