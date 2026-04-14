import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.showBottomNav = true,
    this.showAppBar = false,
  });

  final Widget child;
  final bool showBottomNav;
  final bool showAppBar;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _indexForLocation(String location) {
    if (location.startsWith('/roadmap/')) {
      return 1;
    }

    if (location == '/daily-challenge') {
      return 2;
    }

    if (location == '/interview' || location == '/interview-session') {
      return 3;
    }

    if (location == '/profile' || location == '/progress') {
      return 4;
    }

    if (location == '/language-hub' ||
        location == '/home' ||
        location.startsWith('/lesson/')) {
      return 0;
    }

    return 0;
  }

  void _onTap(int index) {
    switch (index) {
      case 0:
        context.go('/language-hub');
        return;
      case 1:
        context.go('/roadmap/python');
        return;
      case 2:
        context.go('/daily-challenge');
        return;
      case 3:
        context.go('/interview');
        return;
      case 4:
        context.go('/profile');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      appBar: widget.showAppBar ? AppBar() : null,
      body: widget.child,
      bottomNavigationBar: widget.showBottomNav
          ? Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                ),
              ),
              child: SizedBox(
                height: 64,
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: _onTap,
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFF58CC02),
                  unselectedItemColor: const Color(0xFF777777),
                  selectedLabelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Text('🌐', style: TextStyle(fontSize: 20)),
                      label: 'Languages',
                    ),
                    BottomNavigationBarItem(
                      icon: Text('🗺️', style: TextStyle(fontSize: 20)),
                      label: 'Roadmap',
                    ),
                    BottomNavigationBarItem(
                      icon: Text('📅', style: TextStyle(fontSize: 20)),
                      label: 'Challenge',
                    ),
                    BottomNavigationBarItem(
                      icon: Text('🎯', style: TextStyle(fontSize: 20)),
                      label: 'Interview',
                    ),
                    BottomNavigationBarItem(
                      icon: Text('👤', style: TextStyle(fontSize: 20)),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
