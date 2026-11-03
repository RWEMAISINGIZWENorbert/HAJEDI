
import 'package:hajedi/data/expense.dart';

abstract class ExpenseState {}

class ExpensesLoadingState extends ExpenseState {}

class ExpensesLoadedState extends ExpenseState {
  final List<Expense> expenses;

  ExpensesLoadedState(this.expenses);
}

class ExpenseCreatingState extends ExpenseState {}

class ExpenseCreatedState extends ExpenseState {
  final Expense expense;

  ExpenseCreatedState(this.expense);
}

class ExpenseErrorState extends ExpenseState {
  final String message;

  ExpenseErrorState(this.message);
}