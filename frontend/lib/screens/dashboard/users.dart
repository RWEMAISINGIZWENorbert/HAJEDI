import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/user/user_bloc.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/confirmation_dialog.dart';
import 'package:hajedi/widgets/loading.dart';
import 'package:hajedi/widgets/user/user_bottom_sheet_modal.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(LoadUsers());
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarComponent(
        title: loc.users,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UsersLoadingState) {
            return  Center(child: Loading());
          }

          if (state is UsersLoadedState) {
            final users = state.users;

            if (users.isEmpty) {
              // return Center(child: Text(loc.no_users));
              return Center(child: Text("No users available"));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildRow(
                    name: loc.name,
                    role: loc.role,
                    password: loc.password,
                    actions: loc.actions,
                    isHeader: true,
                    context: context,
                  ),
                  const Divider(),
                  ...users.map((user) {
                    return _buildRow(
                      name: user.name,
                      role: user.role,
                      password: user.password,
                      actions: '',
                      isHeader: false,
                      context: context,
                      onRemove: () {
                        // context.read<UserBloc>().add(DeleteUserLocal(userId: user.id));
                        showConfirmationDialog(
                          context,
                          title: loc.delete_user,
                          content: loc.are_you_sure_delete_user,
                          onConfirm: () {
                            context.read<UserBloc>().add(DeleteUserLocal(clientId: user.clientId));
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        );
                      },
                      onEdit: () {
                        showUserBottomSheetModal(
                          context,
                          user: user,
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          }

          if (state is RequestFailureState) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('No users'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showUserBottomSheetModal(context),
        icon: const Icon(Icons.add),
        label: Text(loc.new_user),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
     );
  }

  Widget _buildRow({
    required String name,
    required String role,
    required String password,
    required String actions,
    bool isHeader = false,
    VoidCallback? onRemove,
    VoidCallback? onEdit,
    required BuildContext context,
  }) {
    final style = isHeader
        ? Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Theme.of(context).primaryColor,
            )
        : Theme.of(context).textTheme.displaySmall;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(isHeader ? name : name, style: style),
          ),
          Expanded(
            flex: 1,
            child: Text(isHeader ? role : role, style: style),
          ),
          Expanded(
            flex: 1,
            child: Text(isHeader ? password : password, style: style),
          ),
          if (isHeader)
            Expanded(
              flex: 1,
              child: Text(actions, style: style),
            )
          else
            Expanded(
              flex: 0,
              child: Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, color: Colors.green),
                  ),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}