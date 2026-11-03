
import 'package:flutter/material.dart';
import 'package:hajedi/screens/dashboard/dashboard.dart';
import 'package:hajedi/screens/dashboard/products.dart';
import 'package:hajedi/screens/dashboard/reports.dart';
import 'package:hajedi/screens/dashboard/users.dart';


class ScreenNavigator {
    static Widget getBodyContent(int index) {
      switch (index) {
        case 0: return const Dashboard();
        case 1: return const Products();
        case 2: return const Reports();
        case 3: return const Users();
        default: return const Dashboard();
      }
    }
}