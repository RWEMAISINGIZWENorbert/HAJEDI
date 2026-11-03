

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/user/user_bloc.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/widgets/animated_snackbar.dart';
import 'package:hajedi/widgets/user/user_form.dart';
import 'package:iconly/iconly.dart';

Future<dynamic> showUserBottomSheetModal(
  BuildContext context,
  {User? user}
){
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12), 
          topRight: Radius.circular(12)
        ),
        color: Theme.of(context).cardColor,
      ),
      child: SingleChildScrollView(
         child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user != null
                          // ? '${loc.edit_user}'
                          ? "Update User"
                          : 'Add New User',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(IconlyLight.close_square),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Form
              Padding(
                padding: const EdgeInsets.all(16),
                child: UserForm(
                  user: user,
                  isEditMode: user != null,
                  onUserSaved: (User savedUser) {
                    if (user != null) {
                      // Update existing customer
                      context.read<UserBloc>().add(
                        UpdateUserLocal(clientId: user.clientId, user: savedUser),
                      );
                      showAnimatedSnackBar(context, "User Updated Successfully");
                    } else {
                      // Add new customer
                      context.read<UserBloc>().add(
                        AddUserLocal(user: savedUser),
                      );
                      showAnimatedSnackBar(context, "User Added successfully");
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          )
        ),
      ),
    )
  );
}