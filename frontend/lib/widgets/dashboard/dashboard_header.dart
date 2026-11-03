import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:iconly/iconly.dart';

class DashboardHeader extends StatelessWidget {
  final String? userName;
  final bool isPopoverActive;
  final VoidCallback onAvatarTap;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.isPopoverActive,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${DateTime.now().hour < 12 ? l10n.good_morning : l10n.good_afternoon} ,\n',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                TextSpan(
                  text: '$userName',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).hintColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            InkWell(
              onTap: onAvatarTap,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).cardColor,
                child: Icon(IconlyLight.setting)
              ),
            ),
          ],
        ),
      ],
    );
  }
}
