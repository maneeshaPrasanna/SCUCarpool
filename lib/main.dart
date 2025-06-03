import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'navigation/router.dart';
import 'blocs/authentication/bloc/authentication_bloc.dart';
import 'repositories/authentication/authentication_repository.dart';
import 'location/location_cubit.dart';
import 'offerRide/cubit/offer_ride_cubit.dart';
import 'ride/cubit/ride_cubit.dart';
import 'repositories/user_provider.dart';
import 'theme/theme.dart';
import 'theme/cubit/theme_cubit.dart';
import 'theme/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
  ]);

  await FirebaseMessaging.instance.requestPermission();
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

  Bloc.observer = const AppBlocObserver();

  runApp(MyApp());
}

class AppBlocObserver extends BlocObserver {
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

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme =
        createTextTheme(context, "Roboto", "Playfair Display");

    MaterialTheme theme = MaterialTheme(textTheme);

    return RepositoryProvider(
      create: (context) => AuthenticationRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => authenticationBloc
              ..add(
                AuthenticationInitializeEvent(
                  authenticationRepository:
                      RepositoryProvider.of<AuthenticationRepository>(context),
                ),
              ),
          ),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(create: (context) => LocationAutocompleteCubit()),
          BlocProvider(
              create: (_) => RideCubit(firestore: FirebaseFirestore.instance)),
          BlocProvider(
              create: (_) => OfferRideCubit(FirebaseFirestore.instance)),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {},
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Santa Clara',
                theme: theme.light(),
                darkTheme: theme.dark(),
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
