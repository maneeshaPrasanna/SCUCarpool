import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:provider/provider.dart';

import 'blocs/authentication/bloc/authentication_bloc.dart';
import 'firebase_options.dart';
import 'navigation/router.dart';
import 'repositories/authentication/authentication_repository.dart';
import 'theme/cubit/theme_cubit.dart';
import 'theme/util.dart';
import 'animations/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
  ]);

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
      Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
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
            create: (context) {
              return authenticationBloc
                ..add(AuthenticationInitializeEvent(
                    authenticationRepository:
                        RepositoryProvider.of<AuthenticationRepository>(
                            context)));
            },
          ),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider<LocationAutocompleteCubit>(
              create: (context) => LocationAutocompleteCubit()),
          BlocProvider<RideCubit>(
              create: (_) => RideCubit(firestore: FirebaseFirestore.instance)),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          BlocProvider(
              create: (_) => OfferRideCubit(FirebaseFirestore.instance)),
        ],
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {},
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'SCU Carpool',
                theme: theme.light(),
                darkTheme: theme.dark(),
                highContrastTheme: theme.lightHighContrast(),
                highContrastDarkTheme: theme.darkHighContrast(),
                themeMode: state.themeMode,
                home: const SplashScreen(), //
                onGenerateRoute: (settings) {
                  if (settings.name == '/home') {
                    return MaterialPageRoute(
                      builder: (_) => MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        title: 'SCU Carpool',
                        theme: theme.light(),
                        darkTheme: theme.dark(),
                        highContrastTheme: theme.lightHighContrast(),
                        highContrastDarkTheme: theme.darkHighContrast(),
                        themeMode: state.themeMode,
                        routerConfig: router(authenticationBloc),
                      ),
                    );
                  }
                  return null;
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
