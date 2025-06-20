import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:santa_clara/location/location_cubit.dart';
import 'package:santa_clara/offerRide/cubit/offer_ride_cubit.dart';
import 'package:santa_clara/repositories/user_provider.dart';
import 'package:santa_clara/ride/cubit/ride_cubit.dart';
import 'package:santa_clara/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

import 'blocs/authentication/bloc/authentication_bloc.dart';
import 'firebase_options.dart';
import 'navigation/router.dart';
import 'repositories/authentication/authentication_repository.dart';
import 'theme/cubit/theme_cubit.dart';
import 'theme/util.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure Firebase UI Auth provider
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
  ]);

  // Ask user permission for notifications
  await FirebaseMessaging.instance.requestPermission();

  // Use local emulator for cloud functions during development
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

  // Observe Bloc transitions globally
  Bloc.observer = const AppBlocObserver();

  runApp(MyApp());
}

class AppBlocObserver extends BlocObserver {
  /// {@macro app_bloc_observer}
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) print(change);
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthenticationBloc authenticationBloc = AuthenticationBloc();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // final brightness = View.of(context).platformDispatcher.platformBrightness;

    // Retrieves the default theme for the platform
    //TextTheme textTheme = Theme.of(context).textTheme;

    // Use with Google Fonts package to use downloadable fonts
    TextTheme textTheme =
        createTextTheme(context, "Roboto", "Playfair Display");

    MaterialTheme theme = MaterialTheme(textTheme);

    return RepositoryProvider(
      create: (context) {
        return AuthenticationRepository();
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              return authenticationBloc
                ..add(AuthenticationInitializeEvent(
                    authenticationRepository:
                        RepositoryProvider.of<AuthenticationRepository>(
                            context)));
              // return authenticationBloc..add(AuthenticationInitializeEvent());
            },
          ),
          BlocProvider(
            create: (context) => ThemeCubit(),
          ),
          BlocProvider<LocationAutocompleteCubit>(
            create: (context) => LocationAutocompleteCubit(),
          ),
          BlocProvider<RideCubit>(
              create: (_) => RideCubit(firestore: FirebaseFirestore.instance)),
          ChangeNotifierProvider(create: (_) => UserProvider()),

          BlocProvider(
              create: (_) => OfferRideCubit(FirebaseFirestore.instance)),

          // Add other Cubits/Providers here
        ],
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {},
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Santa Clara',
                theme: theme.light().copyWith(
                      textTheme:
                          theme.light().textTheme.apply(fontFamily: 'Poppins'),
                    ),
                darkTheme: theme.dark().copyWith(
                      textTheme:
                          theme.dark().textTheme.apply(fontFamily: 'Poppins'),
                    ),
                highContrastTheme: theme.lightHighContrast(),
                highContrastDarkTheme: theme.darkHighContrast(),
                themeMode: state.themeMode,
                routerConfig: router(authenticationBloc),
              );
            },
          ),
        ),
      ),
    );
  }
}
