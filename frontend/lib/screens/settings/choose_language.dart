import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:iconly/iconly.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/text.dart';
import 'package:hajedi/bloc/locale/locale_cubit.dart';

class ChooseLanguage extends StatefulWidget {
  const ChooseLanguage({super.key});

  @override
  State<ChooseLanguage> createState() => _ChooseLanguageState();

}

class _ChooseLanguageState extends State<ChooseLanguage> {
  @override
  Widget build(BuildContext context) {
    final current = context.watch<LocaleCubit>().state ?? Localizations.localeOf(context);
    final selectedCode = current.languageCode;
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
       appBar: AppBarComponent(
        icon: InkWell(
           onTap: () => Navigator.pop(context),
           child: const Icon(
            IconlyLight.arrow_left_circle
           ),
        ), 
        title: loc.choose_language
        ),
       body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
         child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const SizedBox(height: 10),
             InkWell(
               onTap: (){
                context.read<LocaleCubit>().setLocale(const Locale('en'));
                },
                child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 SimpleText(label: loc.lang_english),
                 selectedCode == 'en' ? Icon(Icons.check, color: Theme.of(context).primaryColor,) : const SizedBox()
                ],
               ),
             ),
             const SizedBox(height: 12,),
              InkWell(
                onTap: (){
                context.read<LocaleCubit>().setLocale(const Locale('rw'));
               },
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                SimpleText(label: loc.lang_kinyarwanda),
                 selectedCode == 'rw' ? Icon(Icons.check, color: Theme.of(context).primaryColor,) : const SizedBox()
                ],
                             ),
              ),
             const SizedBox(height: 12,),
          ],
         ),
       ),
    );
  }
}