import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/pages/home/home_page.dart';
import 'package:santa_clara/pages/offer_ride.dart';
import 'package:santa_clara/pages/ride_details.dart';
import 'package:santa_clara/pages/ride_screen.dart';
import 'package:santa_clara/pages/search_page.dart';
import 'package:santa_clara/pages/signIn/sign_in_page.dart';
import 'package:santa_clara/pages/verifyEmail/verify_email_page.dart';
import 'package:santa_clara/ride/cubit/ride_cubit.dart';
import 'package:santa_clara/utilities/stream_to_listenable.dart';
import 'package:santa_clara/widgets/scaffold_with_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'my_routes.dart';

List<GoRoute> shellRoutes =
    List.generate(IndexedRoutes().routes.length, (index) {
  return GoRoute(
    name: IndexedRoutes().routes[index].name,
    path: IndexedRoutes().routes[index].path,
    builder: (context, state) {
      return IndexedRoutes().routes[index].child ?? Container();
    },
  );
});

extension on GoRouterState {
  String get inf =>
      'name: $name fullPath: $fullPath matched: $matchedLocation \n'
      '         path: $path topRoute: ${topRoute?.path} ${uri.path}';
}

GoRouter router(AuthenticationBloc authenticationBloc) {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: "Root");
  final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: "Shell");

  return GoRouter(
      //observers: [MyNavObserver()],

      navigatorKey: rootNavigatorKey,
      initialLocation: "/carpool",
      refreshListenable: StreamToListenable([authenticationBloc.stream]),
      redirect: (context, state) {
        print('state.fullPath:begin ${state.fullPath}');
        AuthenticationState authenticationState =
            BlocProvider.of<AuthenticationBloc>(context).state;
        if (authenticationState is AuthenticationVerifyEmailState ||
            authenticationState is AuthenticationEmailVerificationScreenState) {
          return MyRoutes.verifyEmail.path;
        }
        if (authenticationState is! AuthenticationSignedInState) {
          return MyRoutes.signIn.path;
        }
        if (state.fullPath?.startsWith("/signIn") ?? false) {
          print('state.fullPath: ${state.fullPath}');
          return "/carpool";
        }
        return null;
      },
      routes: [
        GoRoute(
          name: MyRoutes.home.name,
          path: MyRoutes.home.path,
          builder: (context, state) {
            print('➡️1 fullPath: ${state.fullPath}');
            print('➡️1 matchedLocation: ${state.matchedLocation}');
            return const HomePage();
          },
          routes: [
            ShellRoute(
              // observers: [MyNavObserver()],
              navigatorKey: shellNavigatorKey,
              routes: [
                ...shellRoutes,
                GoRoute(
                  path: MyRoutes.planYourRide.path,
                  name: MyRoutes.planYourRide.name,
                  builder: (context, state) {
                    print('➡️2 fullPath: ${state.fullPath}');
                    print('➡️2 matchedLocation: ${state.matchedLocation}');
                    return const PlanYourRidePage();
                  },
                  routes: [
                    GoRoute(
                      path: MyRoutes.rideScreen.path,
                      name: MyRoutes.rideScreen.name,
                      builder: (context, state) {
                        print('➡️3 fullPath: ${state.fullPath}');
                        print('➡️3 matchedLocation: ${state.matchedLocation}');
                        return const RideScreen();
                      },
                      routes: [
                        GoRoute(
                            path: MyRoutes.rideDetails.path,
                            name: MyRoutes.rideDetails.name,
                            builder: (context, state) {
                              print('➡️ fullPath: ${state.fullPath}');
                              print(
                                  '➡️ matchedLocation: ${state.matchedLocation}');
                              final ride = state.extra as Ride;
                              return RideDetailsScreen(ride: ride);
                            }),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  name: MyRoutes.offerRide.name,
                  path: MyRoutes.offerRide.path,
                  builder: (context, state) => const OfferRidePage(),
                ),
              ],
              builder: (context, state, child) {
                return ScaffoldWithNavBar(
                  child: child,
                );
              },
            )
          ],
        ),
        GoRoute(
          name: MyRoutes.verifyEmail.name,
          path: MyRoutes.verifyEmail.path,
          builder: (context, state) => const VerifyEmailPage(),
        ),
        GoRoute(
          name: MyRoutes.signIn.name,
          path: MyRoutes.signIn.path,
          builder: (context, state) => const SignInPage(),
        ),
      ]);
}
