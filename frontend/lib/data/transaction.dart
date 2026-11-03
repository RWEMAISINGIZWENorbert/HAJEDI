enum TransactionType { sale, purchase, expense }

class Transaction {
  final String clientId;
  final TransactionType type;
  final DateTime createdAt;
  final double amount;
  final String status; // syncStatus from individual models
  final Map<String, dynamic> rawData; // Original data for details
  
  // Common fields
  final String? userId;
  final String? paymentMethod;
  
  // Type-specific fields
  final String? customerName; // for sales
  final String? supplierName; // for purchases
  final String? description;  // for expenses
  final String? category;     // for expenses
  
  Transaction({
    required this.clientId,
    required this.type,
    required this.createdAt,
    required this.amount,
    required this.status,
    required this.rawData,
    this.userId,
    this.paymentMethod,
    this.customerName,
    this.supplierName,
    this.description,
    this.category,
  });
  
  // Get display title based on transaction type
  String get displayTitle {
    switch (type) {
      case TransactionType.sale:
        return customerName ?? 'Unknown Customer';
      case TransactionType.purchase:
        return supplierName ?? 'Unknown Supplier';
      case TransactionType.expense:
        return description ?? 'Unknown Expense';
    }
  }
  
  // Get transaction type label
  String get typeLabel {
    switch (type) {
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.expense:
        return 'Expense';
    }
  }
}