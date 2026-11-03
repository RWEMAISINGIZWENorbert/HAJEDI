
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hajedi/widgets/loading.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String label;

  const PrimaryButton({
    super.key, 
    required this.onPressed,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
                 backgroundColor: Theme.of(context).primaryColor,
                 elevation: 0,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(14)
                  )
                 ),
                  child: Center(
                         child: isLoading ? Loading() : Text(label, style: GoogleFonts.poppins(
                           color: Colors.white,
                           fontSize: 18,
                           fontWeight: FontWeight.w400
                         ),
                        ),
                  ),
          ),
    );
  }
}