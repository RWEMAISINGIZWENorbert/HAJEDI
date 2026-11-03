import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_event.dart';
import 'package:hajedi/bloc/transaction/transaction_state.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/screens/dashboard/report_details.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/loading.dart';
import 'package:hajedi/widgets/report/report_card.dart';
import 'package:hajedi/widgets/report/show_filter_bottom_sheet_modal.dart';
import 'package:hajedi/widgets/text.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String? selectedPeriod;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    // Load reports for today on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionBloc>().add(LoadReports(period: ReportPeriod.today));
      setState(() {
        selectedPeriod = selectedPeriod ?? 'today';
      });
    });
  }

  String _getDisplayText(AppLocalizations loc) {
    if (startDate != null && endDate != null) {
      // Display date range
      final formatter = DateFormat('dd/MM/yyyy');
      return '${formatter.format(startDate!)} - ${formatter.format(endDate!)}';
    } else if (selectedPeriod != null) {
      // Display localized period text
      switch (selectedPeriod) {
        case 'today':
          return loc.today;
        case 'yesterday':
          return loc.yesterday;
        case 'thisWeek':
          return loc.this_week;
        case 'thisMonth':
          return loc.this_month;
        case 'thisYear':
          return loc.this_year;
        default:
          return '';
      }
    }
    return loc.today;
  }

  ReportPeriod? _getReportPeriod() {
  if (selectedPeriod == null) return null;
  
  switch (selectedPeriod) {
    case 'today':
      return ReportPeriod.today;
    case 'yesterday':
      return ReportPeriod.yesterday;
    case 'thisWeek':
      return ReportPeriod.thisWeek;
    case 'thisMonth':
      return ReportPeriod.thisMonth;
    case 'thisYear':
      return ReportPeriod.thisYear;
    default:
      return null;
  }
}

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarComponent(
        title: loc.reports,
        actions: [
          InkWell(
            onTap: () async {
              final result = await showFilterBottomSheetModal(
                context,
                loc,
                selectedPeriod: selectedPeriod,
                startDate: startDate,
                endDate: endDate,
              );
              
              if (result != null) {
                setState(() {
                  if (result['period'] != null) {
                    selectedPeriod = result['period'];
                    startDate = null;
                    endDate = null;
                  } else {
                    selectedPeriod = null;
                    startDate = result['startDate'];
                    endDate = result['endDate'];
                  }
                });
              }
            },
            child: const Icon(IconlyLight.filter),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(
              child: Loading(),
            );
          }

          if (state is ReportsLoaded) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              shrinkWrap: true,
              children: [
                Center(
                  child: SimpleText(
                    label: _getDisplayText(loc),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetails(
                          reportType: ReportType.sales,
                          period: _getReportPeriod(),
                          startDate: startDate,
                          endDate: endDate,
                        ),
                      ),
                    );
                  },
                  child: ReportCard(
                    name: loc.sales,
                    totalAmount: state.totalSales,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetails(
                          reportType: ReportType.purchases,
                          period: _getReportPeriod(),
                          startDate: startDate,
                          endDate: endDate,
                        ),
                      ),
                    );
                  },
                  child: ReportCard(
                    name: loc.purchases,
                    totalAmount: state.totalPurchases,
                  ),
                ),
                const SizedBox(height: 16),
                ReportCard(
                  name: loc.expenses,
                  totalAmount: state.totalExpenses,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetails(
                          reportType: ReportType.credits,
                          period: _getReportPeriod(),
                          startDate: startDate,
                          endDate: endDate,
                        ),
                      ),
                    );
                  },
                  child: ReportCard(
                    name: loc.credits,
                    totalAmount: state.totalCredits,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetails(
                          reportType: ReportType.creditsCollected,
                          period: _getReportPeriod(),
                          startDate: startDate,
                          endDate: endDate,
                        ),
                      ),
                    );
                  },
                  child: ReportCard(
                    name: loc.payedCredits,
                    totalAmount: state.collectedCredits,
                  ),
                ),
              ],
            );
          }

          if (state is TransactionsError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const Center(
            child: Loading(),
          );
        },
      ),
    );
  }
}