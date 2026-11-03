import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/expense/expense_event.dart';
import 'package:hajedi/bloc/expense/expense_state.dart';
import 'package:hajedi/core/helpers/sync_queue.dart';
import 'package:hajedi/core/network/sync_manager.dart';
import 'package:hajedi/data/expense.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';


// Bloc
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final Box<Expense> _expenseBox;
  final SyncManager _syncManager;
  final Uuid _uuid = Uuid();

  ExpenseBloc({
    required Box<Expense> expenseBox,
    required SyncManager syncManager,
  })  : _expenseBox = expenseBox,
        _syncManager = syncManager,
        super(ExpensesLoadingState()) {
    on<LoadLocalExpenses>(_onLoadLocalExpenses);
    on<CreateExpenseLocal>(_onCreateExpenseLocal);
    on<RetryExpenseSync>(_onRetryExpenseSync);

    _expenseBox.watch().listen((_) {
      add(LoadLocalExpenses());
    });

    add(LoadLocalExpenses());
  }

  Future<void> _onLoadLocalExpenses(LoadLocalExpenses event, Emitter<ExpenseState> emit) async {
    final expenses = _expenseBox.values.toList();
    emit(ExpensesLoadedState(expenses));
  }

  Future<void> _onCreateExpenseLocal(CreateExpenseLocal event, Emitter<ExpenseState> emit) async {
    emit(ExpenseCreatingState());

    try {
      final clientId = _uuid.v4();
      final userId = 'current_user_id'; // Get from auth

      final expense = Expense(
        id: '',
        clientId: clientId,
        userId: userId,
        description: event.description,
        amount: event.amount,
        category: event.category,
        paymentMethod: event.paymentMethod,
        syncStatus: 'pending',
      );

      await _expenseBox.put(clientId, expense);

      // Enqueue for sync
      await SyncQueue.enqueue(
        entityType: 'expense',
        operationType: 'create',
        payload: expense.toJson(),
      );

      emit(ExpenseCreatedState(expense));
      await _syncManager.syncIfConnected();
      add(LoadLocalExpenses());
    } catch (error) {
      emit(ExpenseErrorState(error.toString()));
    }
  }

  Future<void> _onRetryExpenseSync(RetryExpenseSync event, Emitter<ExpenseState> emit) async {
    final expense = _expenseBox.get(event.clientId);
    if (expense != null && expense.syncStatus == 'rejected') {
      await _expenseBox.put(
        event.clientId,
        expense.copyWith(
          syncStatus: 'pending',
          failureReason: null,
          updatedAt: DateTime.now(),
        ),
      );

      await SyncQueue.enqueue(
        entityType: 'expense',
        operationType: 'create',
        payload: expense.toJson(),
      );

      await _syncManager.syncIfConnected();
    }
  }
}