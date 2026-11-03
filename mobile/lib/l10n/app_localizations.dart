import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_rw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('rw'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HAJEDI CENTER'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'logout'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @choose_language.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get choose_language;

  /// No description provided for @lang_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get lang_english;

  /// No description provided for @lang_kinyarwanda.
  ///
  /// In en, this message translates to:
  /// **'Kinyarwanda'**
  String get lang_kinyarwanda;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @new_user.
  ///
  /// In en, this message translates to:
  /// **'New user'**
  String get new_user;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @please_fill_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get please_fill_all_fields;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @this_week.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get this_week;

  /// No description provided for @this_year.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get this_year;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @packet.
  ///
  /// In en, this message translates to:
  /// **'Packet'**
  String get packet;

  /// No description provided for @sack.
  ///
  /// In en, this message translates to:
  /// **'Sack'**
  String get sack;

  /// No description provided for @crate.
  ///
  /// In en, this message translates to:
  /// **'Crate'**
  String get crate;

  /// No description provided for @crates.
  ///
  /// In en, this message translates to:
  /// **'Crates'**
  String get crates;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @bottles.
  ///
  /// In en, this message translates to:
  /// **'Bottles'**
  String get bottles;

  /// No description provided for @bottle.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get bottle;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @packets.
  ///
  /// In en, this message translates to:
  /// **'Packets'**
  String get packets;

  /// No description provided for @select_purchase_method.
  ///
  /// In en, this message translates to:
  /// **'Select the purchase method'**
  String get select_purchase_method;

  /// No description provided for @select_sale_method.
  ///
  /// In en, this message translates to:
  /// **'Select the sale method'**
  String get select_sale_method;

  /// No description provided for @this_month.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get this_month;

  /// No description provided for @update_user.
  ///
  /// In en, this message translates to:
  /// **'Update user'**
  String get update_user;

  /// No description provided for @add_new_user.
  ///
  /// In en, this message translates to:
  /// **'Add new user'**
  String get add_new_user;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @delete_user.
  ///
  /// In en, this message translates to:
  /// **'Remove user'**
  String get delete_user;

  /// No description provided for @are_you_sure_delete_user.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this user? Once removed, they cannot be easily recovered.'**
  String get are_you_sure_delete_user;

  /// No description provided for @no_products_found.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get no_products_found;

  /// No description provided for @new_product.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get new_product;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @product_type.
  ///
  /// In en, this message translates to:
  /// **'Product type'**
  String get product_type;

  /// No description provided for @select_product_type_method.
  ///
  /// In en, this message translates to:
  /// **'Select the product type'**
  String get select_product_type_method;

  /// No description provided for @units_per_package.
  ///
  /// In en, this message translates to:
  /// **'Units per package'**
  String get units_per_package;

  /// No description provided for @quantity_in_stock.
  ///
  /// In en, this message translates to:
  /// **'Quantity in stock'**
  String get quantity_in_stock;

  /// No description provided for @purchase_method.
  ///
  /// In en, this message translates to:
  /// **'Purchase Method'**
  String get purchase_method;

  /// No description provided for @sale_method.
  ///
  /// In en, this message translates to:
  /// **'Sale Method'**
  String get sale_method;

  /// No description provided for @purchase_cost_per.
  ///
  /// In en, this message translates to:
  /// **'Purchase cost per'**
  String get purchase_cost_per;

  /// No description provided for @selling_price_per.
  ///
  /// In en, this message translates to:
  /// **'Selling price per'**
  String get selling_price_per;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @in_stock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get in_stock;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @good_morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get good_morning;

  /// No description provided for @good_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get good_afternoon;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @all_transactions.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all_transactions;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @purchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @no_transactions_found.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get no_transactions_found;

  /// No description provided for @transaction_details.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transaction_details;

  /// No description provided for @sync_status.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get sync_status;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payment_method;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @new_customer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get new_customer;

  /// No description provided for @customer_name.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customer_name;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @credit_limit.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit'**
  String get credit_limit;

  /// No description provided for @no_customers_found.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get no_customers_found;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @add_customer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get add_customer;

  /// No description provided for @edit_customer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get edit_customer;

  /// No description provided for @delete_customer.
  ///
  /// In en, this message translates to:
  /// **'Delete Customer'**
  String get delete_customer;

  /// No description provided for @select_customer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get select_customer;

  /// No description provided for @are_you_sure_delete_customer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this customer?'**
  String get are_you_sure_delete_customer;

  /// No description provided for @new_supplier.
  ///
  /// In en, this message translates to:
  /// **'New Supplier'**
  String get new_supplier;

  /// No description provided for @supplier_name.
  ///
  /// In en, this message translates to:
  /// **'Supplier Name'**
  String get supplier_name;

  /// No description provided for @no_suppliers_found.
  ///
  /// In en, this message translates to:
  /// **'No suppliers found'**
  String get no_suppliers_found;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @select_supplier.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get select_supplier;

  /// No description provided for @add_supplier.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get add_supplier;

  /// No description provided for @edit_supplier.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier'**
  String get edit_supplier;

  /// No description provided for @delete_supplier.
  ///
  /// In en, this message translates to:
  /// **'Delete Supplier'**
  String get delete_supplier;

  /// No description provided for @are_you_sure_delete_supplier.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this supplier?'**
  String get are_you_sure_delete_supplier;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @stock_info.
  ///
  /// In en, this message translates to:
  /// **'Stock Info'**
  String get stock_info;

  /// No description provided for @stock_level.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get stock_level;

  /// No description provided for @in_keyword.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get in_keyword;

  /// No description provided for @packet_size.
  ///
  /// In en, this message translates to:
  /// **'Packet Size'**
  String get packet_size;

  /// No description provided for @crate_size.
  ///
  /// In en, this message translates to:
  /// **'Crate Size'**
  String get crate_size;

  /// No description provided for @sack_size.
  ///
  /// In en, this message translates to:
  /// **'Sack Size'**
  String get sack_size;

  /// No description provided for @purchase_info.
  ///
  /// In en, this message translates to:
  /// **'Purchase Info'**
  String get purchase_info;

  /// No description provided for @sell_info.
  ///
  /// In en, this message translates to:
  /// **'Sell Info'**
  String get sell_info;

  /// No description provided for @per.
  ///
  /// In en, this message translates to:
  /// **'Per'**
  String get per;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @date_range.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get date_range;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @pay_credit.
  ///
  /// In en, this message translates to:
  /// **'Pay Credit'**
  String get pay_credit;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @no_credits.
  ///
  /// In en, this message translates to:
  /// **'No credits found'**
  String get no_credits;

  /// No description provided for @select_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get select_payment_method;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @payedCredits.
  ///
  /// In en, this message translates to:
  /// **'Payed Credits'**
  String get payedCredits;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'rw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'rw':
      return AppLocalizationsRw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
