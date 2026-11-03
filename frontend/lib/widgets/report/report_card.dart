
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hajedi/widgets/loading.dart';
import 'package:intl/intl.dart';

// import 'package:store_app/components/ui/input/sales_trend.dart';
class ReportCard extends StatelessWidget {
  final String name;
  final double totalAmount;
  final bool isLoading;

  const ReportCard({
    super.key,
    required this.name,
    required this.totalAmount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      // width: screenWidth <= 450 ? screenWidth / 1.6 : screenWidth / 4,
      width: screenWidth <= 450
          ? screenWidth / 1.6
          : screenWidth <= 819
              ? screenWidth / 2
              : screenWidth / 4,
      // width: screenWidth <= 819 ? screenWidth / 1.6 : screenWidth / 4,
      height: screenHeight <= 714 ? 178.5 : screenHeight / 4,
      // height: 320,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).hintColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if(isLoading) ...[
             const Center(child: Loading()),
            ] else ...[
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        // text: totalAmount.toStringAsFixed(0),
                        text: _formatNumber(totalAmount),
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: " RWF",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              ]
            ]
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    final numberFormat = NumberFormat.compact(locale: 'en');
    return numberFormat.format(number);
  }
}
