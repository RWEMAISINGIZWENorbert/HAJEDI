import 'package:flutter/material.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:iconly/iconly.dart';

class MyBottomAppBar extends StatelessWidget {
   
   final int currentIndex;
   final Function(int) onItemTapped;
   final bool isAdmin;

  const MyBottomAppBar({
    required this.currentIndex,
    required this.onItemTapped,
    required this.isAdmin,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final loc = AppLocalizations.of(context)!;

    return BottomAppBar(
         height: screenHeight * 0.12,
        color: Colors.transparent,
        child: FutureBuilder(
          future: AuthUtils.readUser(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final isAdmin = user?.role == 'admin';

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: (){
                     onItemTapped(0);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        Icon(
                          currentIndex == 0 ?  IconlyBold.home: IconlyLight.home,
                          // color: currentIndex == 0 ? Theme.of(context).primaryColor: Colors.white70,
                          color: currentIndex == 0 ? Theme.of(context).primaryColor  : Theme.of(context).hintColor,
                          size: 30,
                          ),
                        Flexible ( 
                          child: Text(
                            loc.home,
                             style: currentIndex == 0 ? Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).primaryColor) : Theme.of(context).textTheme.labelSmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1
                             )
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    onItemTapped(1);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        Icon(
                         currentIndex == 1 ? IconlyBold.bag : IconlyLight.bag,
                          size: 30,
                          color: currentIndex == 1 ? Theme.of(context).primaryColor  : Theme.of(context).hintColor,
                          ),
                       Flexible( child: Text(
                          loc.products, 
                           style: currentIndex == 1 ? Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).primaryColor) : Theme.of(context).textTheme.labelSmall,
                           overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                           )
                       )
                    ],
                  ),
                ),
                 if (isAdmin)
                  GestureDetector(
                    onTap: (){
                      onItemTapped(2);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          currentIndex == 2 ?  IconlyBold.paper : IconlyLight.paper,
                          size: 30,
                          color: currentIndex == 2 ? Theme.of(context).primaryColor  : Theme.of(context).hintColor,
                        ),
                        Flexible(
                          child: Text(
                            loc.reports, 
                             style: currentIndex == 2 ? Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).primaryColor) : Theme.of(context).textTheme.labelSmall,
                             overflow: TextOverflow.ellipsis,
                             maxLines: 1,
                             )),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      onItemTapped(3);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          currentIndex == 3 ?  IconlyBold.user_3 : IconlyLight.user_1,
                          size: 30,
                          color: currentIndex == 3 ? Theme.of(context).primaryColor  : Theme.of(context).hintColor,
                        ),
                        Flexible(
                          child: Text(
                            loc.users, 
                             style: currentIndex == 3 ? Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).primaryColor) : Theme.of(context).textTheme.labelSmall,
                             overflow: TextOverflow.ellipsis,
                             maxLines: 1,
                          )),
                      ],
                    ),
                  ),
              ],
            );
          }
        ),
      );
  }
}