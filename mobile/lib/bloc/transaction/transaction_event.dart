enum TransactionFilter { all, sales, purchases, expenses }

enum ReportPeriod {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  thisYear,
}

enum ReportType {
  sales,
  purchases,
  expenses,
  credits,
  creditsCollected,
}

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class FilterTransactions extends TransactionEvent {
  final TransactionFilter filter;

  FilterTransactions(this.filter);
}

class RefreshTransactions extends TransactionEvent {}

class LoadReports extends TransactionEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final ReportPeriod? period;
 
  LoadReports({
    this.startDate,
    this.endDate,
    this.period,
  });
}

class LoadReportDetails extends TransactionEvent {
  final ReportType reportType;
  final DateTime? startDate;
  final DateTime? endDate;
  final ReportPeriod? period;

  LoadReportDetails({
    required this.reportType,
    this.startDate,
    this.endDate,
    this.period,
  });
}