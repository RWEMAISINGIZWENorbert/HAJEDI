import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_event.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/primary_button.dart';
import 'package:hajedi/widgets/report/date_range_picker.dart';
import 'package:hajedi/widgets/text.dart';
import 'package:hajedi/widgets/report/date_period_selector.dart';
import 'package:iconly/iconly.dart';

Future<Map<String, dynamic>?> showFilterBottomSheetModal(
  BuildContext context,
  AppLocalizations loc,
  {String? selectedPeriod,
  DateTime? startDate,
  DateTime? endDate}
) {
  String? currentSelection = selectedPeriod;
  DateTime? startTime = startDate;
  DateTime? endTime = endDate;

  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          color: Theme.of(context).cardColor,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.filter,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(IconlyLight.close_square),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SimpleText(label: loc.date_range),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DatePeriodSelector(
                        label: loc.today,
                        isSelected: currentSelection == 'today',
                        onTap: () {
                          setState(() {
                            currentSelection = 'today';
                            startTime = null;
                            endTime = null;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      DatePeriodSelector(
                        label: loc.yesterday,
                        isSelected: currentSelection == 'yesterday',
                        onTap: () {
                          setState(() {
                            currentSelection = 'yesterday';
                            startTime = null;
                            endTime = null;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      DatePeriodSelector(
                        label: loc.this_week,
                        isSelected: currentSelection == 'thisWeek',
                        onTap: () {
                          setState(() {
                            currentSelection = 'thisWeek';
                            startTime = null;
                            endTime = null;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      DatePeriodSelector(
                        label: loc.this_month,
                        isSelected: currentSelection == 'thisMonth',
                        onTap: () {
                          setState(() {
                            currentSelection = 'thisMonth';
                            startTime = null;
                            endTime = null;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      DatePeriodSelector(
                        label: loc.this_year,
                        isSelected: currentSelection == 'thisYear',
                        onTap: () {
                          setState(() {
                            currentSelection = 'thisYear';
                            startTime = null;
                            endTime = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SimpleText(label: "Custom Dates"),
                ),
                const SizedBox(height: 8),
                DateRangePicker(
                  startDate: startTime,
                  endDate: endTime,
                  onStartDateChanged: (val) {
                    setState(() {
                      startTime = val;
                      currentSelection = null;
                    });
                  },
                  onEndDateChanged: (val) {
                    setState(() {
                      endTime = val;
                      currentSelection = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: loc.apply,
                  onPressed: () {
                    final bloc = context.read<TransactionBloc>();
                    
                    if (startTime == null && endTime == null && currentSelection != null) {
                      // Use period
                      ReportPeriod? period;
                      switch (currentSelection) {
                        case 'today':
                          period = ReportPeriod.today;
                          break;
                        case 'yesterday':
                          period = ReportPeriod.yesterday;
                          break;
                        case 'thisWeek':
                          period = ReportPeriod.thisWeek;
                          break;
                        case 'thisMonth':
                          period = ReportPeriod.thisMonth;
                          break;
                        case 'thisYear':
                          period = ReportPeriod.thisYear;
                          break;
                        default:
                          period = null;
                      }
                      bloc.add(LoadReports(period: period));
                      Navigator.of(context).pop({'period': currentSelection});
                    } else if (startTime != null || endTime != null) {
                      // Use custom dates
                      bloc.add(LoadReports(
                        startDate: startTime,
                        endDate: endTime,
                      ));
                      Navigator.of(context).pop({
                        'startDate': startTime,
                        'endDate': endTime,
                      });
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}