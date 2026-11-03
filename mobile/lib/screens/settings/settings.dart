
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/auth/auth_bloc.dart';
import 'package:hajedi/bloc/theme/theme_bloc.dart';
import 'package:hajedi/bloc/theme/theme_event.dart';
import 'package:hajedi/bloc/theme/theme_state.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:iconly/iconly.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBarComponent(
        icon: InkWell(
           onTap: () => Navigator.pop(context),
           child: const Icon(
            IconlyLight.arrow_left_circle
           ),
        ), 
        title: loc.settings
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            InkWell(
              onTap: (){
                Navigator.pushNamed(context, '/choose-language');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.choose_language),
                  const Icon(IconlyLight.arrow_right_2)
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return ListTile(
                  leading: Icon(
                    // state.themeType == ThemeType.dark
                    state.themeMode == ThemeMode.dark
                        ? IconlyBold.home
                        : IconlyBold.home,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  trailing: Switch(
                    // value: state.themeType == ThemeType.dark,
                    value: state.themeMode == ThemeMode.dark,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (value) {
                      context.read<ThemeBloc>().add(ToggleThemeEvent());
                    },
                  ),
                );
              },
            ),
            const Spacer(),
             BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is LogoutSuccessfully) {
              Navigator.pushNamed(context, '/sign-in');
            }
          },
          child:SafeArea(
               top: false,
               child: _buildListTileSettings(
                  context,
                  loc.logout,
                  textColor: const Color.fromARGB(255, 228, 48, 36),
                  const Icon(
                    Icons.logout,
                    color:  Color.fromARGB(255, 228, 48, 36),
                  ),
                  (){
                    context.read<AuthBloc>().add(LogoutRequested());
                  }
               )
            )
          )
          ],
        ),
      )
    );
  }

  Widget _buildListTileSettings(
    BuildContext context,
    String text, 
    Icon icon, 
    Function onTap,
    {Color? textColor, Widget? trailing}
    ) {
  return ListTile(
    leading: icon,
    title: Padding(
      padding: const EdgeInsets.only(left: 5),
      child: textColor != null 
              ? Text(text, style:  TextStyle(color: textColor),) 
              : Text(text)
    ),
    onTap: () => onTap(),
    trailing: trailing,
    // trailing: const Icon(IconlyLight.arrow_right_2),
  );
}
 

}