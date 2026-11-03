import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListTilePerson extends StatelessWidget {
  final String name;
  final String? telNo;
  final Color? color;
  final double? balance;

  const ListTilePerson({
    super.key,
    required this.name,
    this.telNo, 
    this.color,
    this.balance
    });

  @override
  Widget build(BuildContext context) {
    return  ListTile(
       leading: CircleAvatar(
            backgroundColor: color ??  Colors.primaries[1 % Colors.primaries.length],
            child: Center(
                child: Text(
                  name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      decoration: TextDecoration.none
                      ),
                ),
              ),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        subtitle: telNo != "" ? Text(
           telNo!,  
           style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Theme.of(context).hintColor,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none
                  )
         ) : const SizedBox(),
        
    );
  }
}