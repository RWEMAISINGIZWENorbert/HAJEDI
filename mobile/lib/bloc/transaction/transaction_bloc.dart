import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/sale/sale_bloc.dart';
import 'package:hajedi/bloc/sale/sale_state.dart';
import 'package:hajedi/bloc/purchase/purchase_bloc.dart';
import 'package:hajedi/bloc/purchase/purchase_state.dart';
import 'package:hajedi/bloc/expense/expense_bloc.dart';
import 'package:hajedi/bloc/expense/expense_state.dart';
import 'package:hajedi/bloc/transaction/transaction_event.dart';
import 'package:hajedi/bloc/transaction/transaction_state.dart';
import 'package:hajedi/data/transaction.dart';
import 'package:hajedi/data/sale.dart';
import 'package:hajedi/data/purchase.dart';
import 'package:hajedi/data/expense.dart';
import 'package:hive/hive.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hajedi/data/supplier.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final SaleBloc _saleBloc;
  final PurchaseBloc _purchaseBloc;
  final ExpenseBloc _expenseBloc;

  StreamSubscription? _saleSubscription;
  StreamSubscription? _purchaseSubscription;
  StreamSubscription? _expenseSubscription;

  TransactionBloc({
    required SaleBloc saleBloc,
    required PurchaseBloc purchaseBloc,
    required ExpenseBloc expenseBloc,
  })  : _saleBloc = saleBloc,
        _purchaseBloc = purchaseBloc,
        _expenseBloc = expenseBloc,
        super(TransactionsLoading()) {
    
    // Subscribe to existing bloc state changes
    _saleSubscription = _saleBloc.stream.listen((_) => add(LoadTransactions()));
    _purchaseSubscription = _purchaseBloc.stream.listen((_) => add(LoadTransactions()));
    _expenseSubscription = _expenseBloc.stream.listen((_) => add(LoadTransactions()));
    
    on<LoadTransactions>(_onLoadTransactions);
    on<FilterTransactions>(_onFilterTransactions);
    on<RefreshTransactions>(_onRefreshTransactions);
    on<LoadReports>(_onLoadReports);
    on<LoadReportDetails>(_onLoadReportDetails);

    add(LoadTransactions());
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      // Get current states from existing blocs
      final saleState = _saleBloc.state;
      final purchaseState = _purchaseBloc.state;
      final expenseState = _expenseBloc.state;

      List<Sale> sales = [];
      List<Purchase> purchases = [];
      List<Expense> expenses = [];

      if (saleState is SalesLoadedState) {
        sales = saleState.sales;
      }
      if (purchaseState is PurchasesLoadedState) {
        purchases = purchaseState.purchases;
      }
      if (expenseState is ExpensesLoadedState) {
        expenses = expenseState.expenses;
      }

      final allTransactions = _combineAndSortTransactions(
        sales,
        purchases,
        expenses,
      );

      // Get current filter if we have one
      TransactionFilter currentFilter = TransactionFilter.all;
      if (state is TransactionsLoaded) {
        currentFilter = (state as TransactionsLoaded).currentFilter;
      }

      final filteredTransactions = _filterTransactions(
        allTransactions,
        currentFilter,
      );

      emit(TransactionsLoaded(
        allTransactions: allTransactions,
        filteredTransactions: filteredTransactions,
        currentFilter: currentFilter,
      ));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onFilterTransactions(
    FilterTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      final filteredTransactions = _filterTransactions(
        currentState.allTransactions,
        event.filter,
      );

      emit(TransactionsLoaded(
        allTransactions: currentState.allTransactions,
        filteredTransactions: filteredTransactions,
        currentFilter: event.filter,
      ));
    }
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactions());
  }
   
  Future<void> _onLoadReports( LoadReports event, Emitter<TransactionState> emit, ) async { 
    emit(ReportsLoading()); 
    try { 
      DateTime? startDate = event.startDate; 
      DateTime? endDate = event.endDate; 
      if (event.period != null) {
         final (start, end) = _getDateRangeForPeriod(event.period!); 
         startDate = start; endDate = end;
       } else if (startDate == null && endDate == null) {
         final now = DateTime.now(); 
         startDate = DateTime(now.year, now.month, now.day, 0, 0, 0); 
         endDate = DateTime(now.year, now.month, now.day, 23, 59, 59); 
       } else if (startDate != null && endDate == null) { 
        endDate = DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59); 
      } else if (startDate == null && endDate != null) { 
        startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0); 
      } 

      final saleState = _saleBloc.state; 
      final purchaseState = _purchaseBloc.state;
      final expenseState = _expenseBloc.state; 
      List<Sale> sales = []; 
      List<Purchase> purchases = [];
      List<Expense> expenses = []; 
        if (saleState is SalesLoadedState) { sales = saleState.sales; } 
        if (purchaseState is PurchasesLoadedState) { purchases = purchaseState.purchases; } 
        if (expenseState is ExpensesLoadedState) { expenses = expenseState.expenses; } 
      final filteredSales = sales.where((sale) {
         return sale.createdAt.isAfter(startDate!) && sale.createdAt.isBefore(endDate!); 
         }).toList(); 
      final filteredPurchases = purchases.where((purchase) { 
         return purchase.createdAt.isAfter(startDate!) && purchase.createdAt.isBefore(endDate!); 
         }).toList(); 
      final filteredExpenses = expenses.where((expense) { 
         return expense.createdAt.isAfter(startDate!) && expense.createdAt.isBefore(endDate!); 
         }).toList(); 
      final totalSales = filteredSales.fold<double>( 0.0, (sum, sale) => sum + sale.totalAmount, ); 
      final totalPurchases = filteredPurchases.fold<double>( 0.0, (sum, purchase) => sum + purchase.totalCost, ); 
      final totalExpenses = filteredExpenses.fold<double>( 0.0, (sum, expense) => sum + expense.amount, ); 
      final totalCredits = filteredSales.fold<double>(0.0, (sum, sale) => sale.paymentMethod.toLowerCase() == 'credit' ? sum + sale.totalAmount : sum);
      final collectedCredits = filteredSales.fold<double>(0.0, (sum, sale) => sale.originalPaymentMethod.toLowerCase() == 'credit' && sale.paymentMethod.toLowerCase() != 'credit' ? sum + sale.totalAmount  : sum );

      emit(ReportsLoaded( 
         totalSales: totalSales, 
         totalPurchases: totalPurchases, 
         totalExpenses: totalExpenses, 
         totalCredits: totalCredits,
         collectedCredits: collectedCredits,
         startDate: startDate!, 
         endDate: endDate!, 
         )); 
      } catch (e) { 
         emit(TransactionsError(e.toString())); 
      } 
   } 

Future<void> _onLoadReportDetails(
  LoadReportDetails event,
  Emitter<TransactionState> emit,
) async {
  emit(ReportDetailsLoading());
  try {
    DateTime? startDate = event.startDate;
    DateTime? endDate = event.endDate;
    
    if (event.period != null) {
      final (start, end) = _getDateRangeForPeriod(event.period!);
      startDate = start;
      endDate = end;
    } else if (startDate == null && endDate == null) {
      final now = DateTime.now();
      startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (startDate != null && endDate == null) {
      endDate = DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59);
    } else if (startDate == null && endDate != null) {
      startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
    }

    final saleState = _saleBloc.state;
    final purchaseState = _purchaseBloc.state;
    final expenseState = _expenseBloc.state;
    
    List<Sale> sales = [];
    List<Purchase> purchases = [];
    List<Expense> expenses = [];
    
    if (saleState is SalesLoadedState) {
      sales = saleState.sales;
    }
    if (purchaseState is PurchasesLoadedState) {
      purchases = purchaseState.purchases;
    }
    if (expenseState is ExpensesLoadedState) {
      expenses = expenseState.expenses;
    }

    // Filter by date range
    final filteredSales = sales.where((sale) {
      return sale.createdAt.isAfter(startDate!) && sale.createdAt.isBefore(endDate!);
    }).toList();
    
    final filteredPurchases = purchases.where((purchase) {
      return purchase.createdAt.isAfter(startDate!) && purchase.createdAt.isBefore(endDate!);
    }).toList();
    
    final filteredExpenses = expenses.where((expense) {
      return expense.createdAt.isAfter(startDate!) && expense.createdAt.isBefore(endDate!);
    }).toList();

    // Filter by report type
    List<Transaction> reportTransactions = [];
    
    switch (event.reportType) {
      case ReportType.sales:
        final salesTransactions = filteredSales.map(_saleToTransaction).toList();
        // Consolidate items by productClientId
        if (salesTransactions.isNotEmpty) {
          reportTransactions = [_createConsolidatedTransaction(salesTransactions, event.reportType)];
        }
        break;
      case ReportType.purchases:
        final purchasesTransactions = filteredPurchases.map(_purchaseToTransaction).toList();
        // Consolidate items by productClientId
        if (purchasesTransactions.isNotEmpty) {
          reportTransactions = [_createConsolidatedTransaction(purchasesTransactions, event.reportType)];
        }
        break;
      case ReportType.expenses:
        reportTransactions = filteredExpenses.map(_expenseToTransaction).toList();
        break;
      case ReportType.credits:
        reportTransactions = filteredSales
            .where((sale) => sale.paymentMethod.toLowerCase() == 'credit')
            .map(_saleToTransaction)
            .toList();
        break;
      case ReportType.creditsCollected:
        reportTransactions = filteredSales
            .where((sale) => 
                sale.originalPaymentMethod.toLowerCase() == 'credit' && 
                sale.paymentMethod.toLowerCase() != 'credit')
            .map(_saleToTransaction)
            .toList();
        break;
    }

    // Sort by createdAt descending (newest first)
    reportTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(ReportDetailsLoaded(
      transactions: reportTransactions,
      reportType: event.reportType,
      startDate: startDate!,
      endDate: endDate!,
    ));
  } catch (e) {
    emit(TransactionsError(e.toString()));
  }
}

  (DateTime, DateTime) _getDateRangeForPeriod(ReportPeriod period) {
     final now = DateTime.now();
     switch (period) {
       case ReportPeriod.today:
         final start = DateTime(now.year, now.month, now.day, 0, 0, 0); 
         final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
         return (start, end); 
       case ReportPeriod.yesterday: 
         final yesterday = now.subtract(const Duration(days: 1)); 
         final start = DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0, 0); 
         final end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59); 
         return (start, end); 
       case ReportPeriod.thisWeek: 
         final currentDay = now.weekday; 
         final daysToSubtract = currentDay - 1; 
         final startOfweek = now.subtract(Duration(days: daysToSubtract)); 
         final start = DateTime(startOfweek.year, startOfweek.month, startOfweek.day, 0, 0, 0); 
         final end = DateTime(now.year, now.month, now.day, 23, 59, 59); 
         return (start, end); 
       case ReportPeriod.thisMonth: 
         final start = DateTime(now.year, now.month, 1, 0, 0, 0); 
         final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59); 
         return (start, end); 
       case ReportPeriod.thisYear: 
         final start = DateTime(now.year, 1, 1, 0, 0, 0); 
         final end = DateTime(now.year, 12, 31, 23, 59, 59); 
         return (start, end); 
     } 
   } 

  List<Transaction> _combineAndSortTransactions(
    List<Sale> sales,
    List<Purchase> purchases,
    List<Expense> expenses,
  ) {
    final allTransactions = [
      ...sales.map(_saleToTransaction),
      ...purchases.map(_purchaseToTransaction),
      ...expenses.map(_expenseToTransaction),
    ];

    // Sort by createdAt descending (newest first)
    allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allTransactions;
  }

  List<Transaction> _filterTransactions(
    List<Transaction> transactions,
    TransactionFilter filter,
  ) {
    switch (filter) {
      case TransactionFilter.all:
        return transactions;
      case TransactionFilter.sales:
        return transactions.where((t) => t.type == TransactionType.sale).toList();
      case TransactionFilter.purchases:
        return transactions.where((t) => t.type == TransactionType.purchase).toList();
      case TransactionFilter.expenses:
        return transactions.where((t) => t.type == TransactionType.expense).toList();
    }
  }

  Transaction _saleToTransaction(Sale sale) {
   // Retrieve customer name from local Hive
   final customerBox = Hive.box<Customer>('customers');
   final customer = customerBox.get(sale.customerClientId);
   final customerName = customer?.name ?? "";
    

    return Transaction(
      clientId: sale.clientId,
      type: TransactionType.sale,
      createdAt: sale.createdAt,
      amount: sale.totalAmount,
      status: sale.syncStatus,
      rawData: sale.toJson(),
      userId: sale.userId,
      paymentMethod: sale.paymentMethod,
      customerName: customerName, // Would need to look up actual name
    );
  }

  Transaction _purchaseToTransaction(Purchase purchase) {
    
    final supplierBox = Hive.box<Supplier>('suppliers');
    final supplier = supplierBox.get(purchase.supplierClientId);
    final supplierName = supplier?.name ?? "";

    return Transaction(
      clientId: purchase.clientId,
      type: TransactionType.purchase,
      createdAt: purchase.createdAt,
      amount: purchase.totalCost,
      status: purchase.syncStatus,
      rawData: purchase.toJson(),
      userId: purchase.userId,
      paymentMethod: purchase.paymentMethod,
      supplierName: supplierName, // Would need to look up actual name
    );
  }

  Transaction _expenseToTransaction(Expense expense) {
    return Transaction(
      clientId: expense.clientId,
      type: TransactionType.expense,
      createdAt: expense.createdAt,
      amount: expense.amount,
      status: expense.syncStatus,
      rawData: expense.toJson(),
      userId: expense.userId,
      paymentMethod: expense.paymentMethod,
      description: expense.description,
      category: expense.category,
    );
  }

  @override
  Future<void> close() async {
    await _saleSubscription?.cancel();
    await _purchaseSubscription?.cancel();
    await _expenseSubscription?.cancel();
    return super.close();
  }
  

/// Consolidates items from multiple transactions by productClientId
/// Returns a map where key is productClientId and value is consolidated item data
Map<String, Map<String, dynamic>> _consolidateItems(List<Transaction> transactions) {
  final Map<String, Map<String, dynamic>> consolidated = {};
  
  for (final transaction in transactions) {
    final items = transaction.rawData['items'] as List?;
    if (items == null) continue;
    
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      
      final productClientId = item['productClientId']?.toString();
      if (productClientId == null || productClientId.isEmpty) continue;
      
      final quantity = (item['quantity'] as num?)?.toDouble() ?? 0.0;
      final price = transaction.type == TransactionType.purchase
          ? (item['purchaseCost'] as num?)?.toDouble() ?? 0.0
          : (item['price'] as num?)?.toDouble() ?? 0.0;
      final totalAmount = (item['totalAmount'] as num?)?.toDouble() ?? (price * quantity);
      
      if (consolidated.containsKey(productClientId)) {
        // Sum quantities and amounts
        final existing = consolidated[productClientId]!;
        existing['quantity'] = (existing['quantity'] as num) + quantity;
        existing['totalAmount'] = (existing['totalAmount'] as num) + totalAmount;
        // Keep the price from the first occurrence or calculate average
        existing['price'] = price;
        existing['purchaseCost'] = price;
      } else {
        // Add new item
        consolidated[productClientId] = {
          'productClientId': productClientId,
          'productId': item['productId']?.toString() ?? '',
          'quantity': quantity,
          'price': price,
          'purchaseCost': price,
          'totalAmount': totalAmount,
        };
      }
    }
  }
  
  return consolidated;
}

/// Creates a consolidated transaction from multiple transactions
Transaction _createConsolidatedTransaction(List<Transaction> transactions, ReportType reportType) {
  if (transactions.isEmpty) {
    // Return empty transaction if no transactions
    return Transaction(
      clientId: '',
      type: reportType == ReportType.sales ? TransactionType.sale : TransactionType.purchase,
      createdAt: DateTime.now(),
      amount: 0.0,
      status: 'synced',
      rawData: {'items': []},
    );
  }
  
  // Consolidate items
  final consolidatedItems = _consolidateItems(transactions);
  final itemsList = consolidatedItems.values.toList();
  
  // Calculate total amount
  final totalAmount = transactions.fold<double>(
    0.0,
    (sum, t) => sum + t.amount,
  );
  
  // Use the most recent transaction's data for common fields
  final mostRecent = transactions.reduce((a, b) => 
    a.createdAt.isAfter(b.createdAt) ? a : b
  );
  
  // Create consolidated rawData
  final consolidatedRawData = Map<String, dynamic>.from(mostRecent.rawData);
  consolidatedRawData['items'] = itemsList;
  consolidatedRawData['totalItems'] = itemsList.fold<int>(
    0,
    (sum, item) => sum + ((item['quantity'] as num).toInt()),
  );
  
  return Transaction(
    clientId: mostRecent.clientId,
    type: mostRecent.type,
    createdAt: mostRecent.createdAt,
    amount: totalAmount,
    status: mostRecent.status,
    rawData: consolidatedRawData,
    userId: mostRecent.userId,
    paymentMethod: mostRecent.paymentMethod,
    customerName: mostRecent.customerName,
    supplierName: mostRecent.supplierName,
  );
}
}