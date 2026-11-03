
abstract class ExpenseEvent {}

class LoadLocalExpenses extends ExpenseEvent {}

class CreateExpenseLocal extends ExpenseEvent {
  final String description;
  final double amount;
  final String category;
  final String paymentMethod;

  CreateExpenseLocal({
    required this.description,
    required this.amount,
    required this.category,
    this.paymentMethod = 'cash',
  });
}

class RetryExpenseSync extends ExpenseEvent {
  final String clientId;

  RetryExpenseSync(this.clientId);
}