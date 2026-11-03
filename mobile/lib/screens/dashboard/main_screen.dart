
import 'package:flutter/material.dart';
import 'package:hajedi/widgets/admin_dashboard_navigator.dart';
import 'package:hajedi/widgets/bottom_app_bar.dart';


class MainScreen extends StatefulWidget {
  final int? activeIndex;
  const MainScreen({super.key, this.activeIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  // bool? _isAdmin;
  bool _isAdmin = true;

  @override
  void initState() {
    super.initState();
     _currentIndex = widget.activeIndex ?? 0;
    // _loadAdminStatus();
  }

  // Future<void> _loadAdminStatus() async {
  //   final isAdmin = await AuthManager.isAdmin();
  //   if (mounted) {
  //     setState(() {
  //       _isAdmin = isAdmin;
  //     });
  //   }
  // }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex > 0) {
          setState(() {
            _currentIndex = _currentIndex - 1; // Move to previous tab
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.only(top: 22),
          child: ScreenNavigator.getBodyContent(_currentIndex),
        ),
        bottomNavigationBar: MyBottomAppBar(
          currentIndex: _currentIndex,
          onItemTapped: _onItemTapped,
          isAdmin: _isAdmin,
        ),
      ),
    );
  }
}