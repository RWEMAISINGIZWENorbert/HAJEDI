import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hajedi/data/quick_actions_model.dart';
import 'package:hajedi/l10n/app_localizations.dart';

class QuickActionsBtn extends StatelessWidget {
  const QuickActionsBtn({super.key});

  @override
  Widget build(BuildContext context) {
    List<QuickActionsModel> quickActions = QuickActionsModel.initActions();
    final loc = AppLocalizations.of(context)!;

    return Container(
      // height: 160,
      height: 135,
      margin: const  EdgeInsets.only(left: 16, right: 16, bottom: 0),
      child:  GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 118,
          crossAxisSpacing: 3,
          mainAxisSpacing: 0,
          childAspectRatio: 1.4,
        ),
        itemCount: quickActions.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
                 GestureDetector(
                    onTap: () {
                      switch (index) {
                        case 0:
                          Navigator.pushNamed(
                            context,
                            '/sale',
                          );
                          break;
                        case 1:
                          Navigator.pushNamed(
                            context,
                            '/purchase',
                          );
                          break;
                        case 2:
                          Navigator.pushNamed(
                            context,
                            '/transactions',
                          );
                          break;
                        case 3:
                          Navigator.pushNamed(
                            context,
                            '/customers',
                          );
                          break;
                        case 4:
                          Navigator.pushNamed(
                            context,
                            '/suppliers',
                          );
                          break;
                        case 5:
                          Navigator.pushNamed(
                            context,
                            '/credits',
                          );  
                          break;
                        // case 5:
                        //   context.read<AuthBloc>().add(const LogoutEvent());
                        //   //  () async {
                        //   //     print(await AuthManager.readAuth());
                        //   //  };                        
                        //   break;
                      }
                    },
                    child: Container(
                      height: 45,
                      width: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: quickActions[index].color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: quickActions[index].icon,
                    ),
                  ),
              Text(
                quickActions[index].label(loc),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).hintColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
