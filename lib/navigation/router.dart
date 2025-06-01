import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/pages/home/home_page.dart';
import 'package:santa_clara/pages/offer_ride.dart';
import 'package:santa_clara/pages/ride_details.dart';
import 'package:santa_clara/pages/ride_screen.dart';
import 'package:santa_clara/pages/search_page.dart';
import 'package:santa_clara/pages/signIn/sign_in_page.dart';
import 'package:santa_clara/pages/verifyEmail/verify_email_page.dart';
import 'package:santa_clara/utilities/stream_to_listenable.dart';
import 'package:santa_clara/widgets/scaffold_with_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'my_routes.dart';
import 'package:santa_clara/pages/ride_history_screen.dart';
import 'package:santa_clara/animations/splash_screen.dart';

List<GoRoute> shellRoutes = List.generate(IndexedRoutes().routes.length, (index) {
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
    navigatorKey: rootNavigatorKey,
    initialLocation: "/splash",
    refreshListenable: StreamToListenable([authenticationBloc.stream]),
    redirect: (context, state) {
      // Don't redirect if on splash screen
      if (state.fullPath == '/splash') return null;

      final authState = BlocProvider.of<AuthenticationBloc>(context).state;

      if (authState is AuthenticationVerifyEmailState ||
          authState is AuthenticationEmailVerificationScreenState) {
        return MyRoutes.verifyEmail.path;
      }

      if (authState is! AuthenticationSignedInState) {
        return MyRoutes.signIn.path;
      }

      if (state.fullPath?.startsWith("/signIn") ?? false) {
        return "/carpool";
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/ride-history',
        builder: (context, state) => RideHistoryScreen(),
      ),
      GoRoute(
        name: MyRoutes.home.name,
        path: MyRoutes.home.path,
        builder: (context, state) => const HomePage(),
        routes: [
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            routes: [
              ...shellRoutes,
              GoRoute(
                path: MyRoutes.planYourRide.path,
                name: MyRoutes.planYourRide.name,
                builder: (context, state) => const PlanYourRidePage(),
                routes: [
                  GoRoute(
                    path: MyRoutes.rideScreen.path,
                    name: MyRoutes.rideScreen.name,
                    builder: (context, state) => const RideScreen(),
                    routes: [
                      GoRoute(
                        path: MyRoutes.rideDetails.path,
                        name: MyRoutes.rideDetails.name,
                        builder: (context, state) {
                          final ride = state.extra as Ride;
                          return RideDetailsScreen(ride: ride);
                        },
                      ),
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
            builder: (context, state, child) => ScaffoldWithNavBar(child: child),
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
    ],
  );
}