import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/auth/auth_bloc.dart';
import 'package:hajedi/bloc/sell_cart/sell_cart_bloc.dart';
import 'package:hajedi/bloc/purchase_cart/purchase_cart_bloc.dart';
import 'package:hajedi/bloc/expense/expense_bloc.dart';
import 'package:hajedi/bloc/locale/locale_cubit.dart';
import 'package:hajedi/bloc/purchase/purchase_bloc.dart';
import 'package:hajedi/bloc/sale/sale_bloc.dart';
import 'package:hajedi/bloc/theme/theme_bloc.dart';
import 'package:hajedi/bloc/theme/theme_state.dart';
import 'package:hajedi/bloc/transaction/transaction_bloc.dart';
import 'package:hajedi/bloc/user/user_bloc.dart';
import 'package:hajedi/bloc/customer/customer_bloc.dart';
import 'package:hajedi/bloc/supplier/supplier_bloc.dart';
import 'package:hajedi/core/network/sync_coordinator.dart';
import 'package:hajedi/core/network/sync_manager.dart';
import 'package:hajedi/core/theme/theme.dart';
import 'package:hajedi/data/expense.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/data/purchase.dart';
import 'package:hajedi/data/sale.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hajedi/data/supplier.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/l10n/fallback_localizations.dart';
import 'package:hajedi/repository/auth_repository.dart';
import 'package:hajedi/screens/actions/Sale.dart' as sale_screen;
import 'package:hajedi/screens/actions/credits.dart';
import 'package:hajedi/screens/actions/customers.dart';
import 'package:hajedi/screens/actions/purchase.dart' as purchase_screen;
import 'package:hajedi/screens/actions/suppliers.dart';
import 'package:hajedi/screens/actions/transactions.dart';
import 'package:hajedi/screens/auth/sign_in.dart';
import 'package:hajedi/screens/dashboard/main_screen.dart';
import 'package:hajedi/screens/product/new_product.dart';
import 'package:hajedi/screens/settings/choose_language.dart';
import 'package:hajedi/screens/settings/settings.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:hajedi/utils/hive_registry.dart';
import 'package:hajedi/widgets/loading.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajedi/bloc/product/product_bloc.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
      ? HydratedStorageDirectory.web
      : HydratedStorageDirectory(
          (await getApplicationSupportDirectory()).path,
        ),
   );
  await HiveRegistry.init();
  await HiveRegistry.clearALlBoxes();
  await AuthUtils.clearAuthData();
  await dotenv.load(fileName: ".env");
  final syncManager = SyncManager.create(
     queueBox: Hive.box<SyncQueueItem>('syncQueue'),
     userBox: Hive.box<User>('users'),
     productBox: Hive.box<Product>('products'),
     saleBox: Hive.box<Sale>('sales'),
     purchaseBox: Hive.box<Purchase>('purchases'),
     expenseBox: Hive.box<Expense>('expenses'),
     customerBox: Hive.box<Customer>('customers'),
     supplierBox: Hive.box<Supplier>('suppliers')
  );
  
  final syncCoordinator = SyncCoordinator(syncManager);

  if (await AuthUtils.isAuthenticated()) {
    await syncManager.start();
    syncCoordinator.start();
  }

  runApp(MyApp(syncManager: syncManager, syncCoordinator: syncCoordinator));
}

class MyApp extends StatelessWidget {
  final SyncManager syncManager;
  final SyncCoordinator syncCoordinator;

  const MyApp({super.key, required this.syncManager, required this.syncCoordinator});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (context) => UserBloc(Hive.box('users'), syncManager)),
        BlocProvider(create: (_) => AuthBloc(authRepository: AuthRepository(),)),
        BlocProvider(create: (_) => ProductBloc(Hive.box('products'),syncManager)..add(LoadLocalProducts()),), 
        BlocProvider(create: (_) => SaleBloc(saleBox: Hive.box<Sale>('sales'), productBox: Hive.box<Product>('products'), syncManager: syncManager)),
        BlocProvider(create: (_) => PurchaseBloc(purchaseBox: Hive.box<Purchase>('purchases'), productBox: Hive.box<Product>('products'), syncManager: syncManager)),
        BlocProvider(create: (_) => ExpenseBloc(expenseBox: Hive.box<Expense>('expenses'), syncManager: syncManager)),
        BlocProvider(create: (_) => CustomerBloc(Hive.box<Customer>('customers'),  syncManager)),
        BlocProvider(create: (_) => SupplierBloc(Hive.box<Supplier>('suppliers'), syncManager)),
        BlocProvider(create: (_) => SellCartBloc()),
        BlocProvider(create: (_) => PurchaseCartBloc()),
        BlocProvider(create: (context) => TransactionBloc(
          saleBloc: context.read<SaleBloc>(),
          purchaseBloc: context.read<PurchaseBloc>(),
          expenseBloc: context.read<ExpenseBloc>(),
        )),
        ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, localState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  routes: {
                     '/choose-language': (context) => const ChooseLanguage(),
                     '/settings': (context) => const Settings(),
                     '/dashboard': (context) => const MainScreen(),
                     '/sign-in': (context) => const SignIn(),
                     '/new-product': (context) => const NewProduct(),
                     '/sale': (context) => const sale_screen.Sale(),
                     '/purchase': (context) => const purchase_screen.Purchase(),
                     '/transactions': (context) => const Transactions(),
                     '/customers': (context) => const Customers(),
                     '/suppliers': (context) => const Suppliers(),
                     '/credits': (context) => const Credits(),
                  },
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  // themeMode: ThemeMode.light,
                  themeMode: themeState.themeMode,
                  locale: localState ?? const Locale('en'),
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                      AppLocalizations.delegate,
                      FallbackMaterialLocalizationsDelegate(),
                      FallbackWidgetsLocalizationsDelegate(),
                      FallbackCupertinoLocalizationsDelegate(),
                    ],
                  localeResolutionCallback: (locale, supported) {
                      if (locale == null) return supported.first;
                      final isSupported = supported.any(
                        (l) => l.languageCode == locale.languageCode,
                      );
                      return isSupported ? locale : const Locale('en');
                    },
                  home: const AuthChecker(
                    child: AuthGate(),
                  ),
                );

            },
          );
        },
      ),
    );
  }
}


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthUtils.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Loading(),
            ),
          );
        }

        if (snapshot.data == true) {
          return const MainScreen();
        }

        return const SignIn();
      },
    );
  }
}


class AuthChecker extends StatefulWidget {
  final Widget child;
 
  const AuthChecker({super.key, required this.child});
 
  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}
 
class _AuthCheckerState extends State<AuthChecker> with WidgetsBindingObserver {
  Timer? _authCheckTimer;
 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Check authentication every 30 seconds
    _authCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkAuthAndRedirect();
    });
  }
 
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authCheckTimer?.cancel();
    super.dispose();
  }
 
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check auth when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _checkAuthAndRedirect();
    }
  }
 
  Future<void> _checkAuthAndRedirect() async {
    final isAuthenticated = await AuthUtils.isAuthenticated();
    
    if (!isAuthenticated && mounted) {
      // Navigate to sign-in if not authenticated
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/sign-in',
        (route) => false,
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
