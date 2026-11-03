import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_event.dart';
import 'package:hajedi/bloc/transaction/transaction_state.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:hajedi/widgets/dashboard/dashboard_card.dart';
import 'package:hajedi/widgets/dashboard/dashboard_header.dart';
import 'package:hajedi/widgets/dashboard/quick_actions_btn.dart';
import 'package:hajedi/widgets/text.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    // Load reports for today on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionBloc>().add(LoadReports());
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Builder(
      builder: (context) {
        return Scaffold(
          body: FutureBuilder(
            future: AuthUtils.readUser(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final userName = user?.name ?? '';
              final role = user?.role ?? '';

              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 4,
                    left: 8,
                    right: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHeader(
                        userName: userName,
                        isPopoverActive: false,
                        onAvatarTap: () {
                          Navigator.pushNamed(
                            context,
                            '/settings',
                          );
                        },
                      ),
                      const SizedBox(height: 12,),
                      SimpleText(label: loc.today),
                      role == 'admin' ? BlocBuilder<TransactionBloc, TransactionState>(
                          builder: (context, state) {
                          if (state is ReportsLoading) {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (state is ReportsLoaded) {
                            return DashboardCard(
                              sales: state.totalSales,
                              purchases: state.totalPurchases,
                              expenses: state.totalExpenses,
                            );
                          }

                          if (state is TransactionsError) {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: Text('Error loading reports'),
                              ),
                            );
                          }

                          return const DashboardCard();
                        },
                      ): const SizedBox(),
                      const SizedBox(height: 12),
                      SimpleText(label: "Actions"),
                      QuickActionsBtn()
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }
}