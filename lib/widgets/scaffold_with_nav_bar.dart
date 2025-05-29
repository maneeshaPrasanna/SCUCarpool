import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:santa_clara/navigation/my_routes.dart';

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  /// The widget to display in the body of the Scaffold.
  /// In this sample, it is a Navigator.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(
          color: Color.fromARGB(255, 129, 30, 45),
          width: 1.0,
        ))),
        child: NavigationBar(
          destinations: List.generate(
            IndexedRoutes().routes.length,
            (index) {
              return NavigationDestination(
                // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                icon: Icon(
                    IndexedRoutes().routes[index].icon ?? Icons.question_mark),
                label: IndexedRoutes().routes[index].label ??
                    IndexedRoutes().routes[index].name,
              );
            },
          ),
          selectedIndex: _calculateSelectedIndex(context),
          onDestinationSelected: (int idx) => _onItemTapped(idx, context),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    int index = IndexedRoutes().getIndex(location);
    if (index > -1) {
      return index;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final String routeName = IndexedRoutes().getName(index);

    // If navigating to Home, clear RideCubit state
    // if (routeName == MyRoutes.home.name) {
    //   context.read<RideCubit>().clearRideSearchState();
    // }
    GoRouter.of(context).goNamed(IndexedRoutes().getName(index));
  }
}
