import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/customer/customer_bloc.dart';
import 'package:hajedi/bloc/customer/customer_state.dart';
import 'package:hajedi/bloc/customer/customer_event.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/customer/customer_bottom_sheet_modal.dart';
import 'package:hajedi/widgets/floating_action_btn.dart';
import 'package:iconly/iconly.dart';
import 'package:hajedi/widgets/loading.dart';
import 'package:hajedi/widgets/list_tile_person.dart';

class Customers extends StatefulWidget {
  const Customers({super.key});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerBloc>().add(LoadCustomers());
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final double screenHeight = MediaQuery.of(context).size.height; 
    
    Color generateColor(String text) {
    // Use the first character's ASCII value to generate a hue
    final int hash = text.codeUnitAt(0);
    // Convert to a hue value between 0 and 360
    final double hue = (hash * 137.5) % 360;
    // Create a color with full saturation and lightness
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
    }


    return Scaffold(
      appBar: AppBarComponent(
        title: loc.customers,
        icon: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(IconlyLight.arrow_left_circle),
        ),
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {

        },
        builder: (context, state) {
          if (state is CustomersLoadingState) {
            return  Center(child: Loading());
          } else if(state is CustomersLoadedState){
             final customers = state.customers;

             if(customers.isEmpty){
               return Center(child: Text(loc.no_customers_found));
             }

             return SizedBox(
               height: screenHeight,
               child: ListView.builder(
                itemCount: state.customers.length,
                 itemBuilder: (context, index) { 
                    final customer = customers[index];
                    return InkWell(
                      onTap: () {},
                      child: ListTilePerson(
                        color: generateColor(customer.name),
                        name: customer.name,
                        telNo: customer.phoneNumber,
                      )
                    );
                 }
               )
       );


          }
           return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionBtn(
        bgColor: Theme.of(context).primaryColor,
        color: Theme.of(context).cardColor,
        onTap: () => showCustomerBottomSheetModal(context),
      ),
    );
  }
}
