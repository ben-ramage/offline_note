import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffoldWithNavbar extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const AppScaffoldWithNavbar({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,

        currentIndex: _calculateSelectedIndex(state),
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(GoRouterState state) {
    final path = state.uri.path;

    if (path.startsWith('/profile')) {
      return 1;
    }

    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/create');
        break;
      case 1:
        context.go('/profile');
        break;
    }
  }
}
