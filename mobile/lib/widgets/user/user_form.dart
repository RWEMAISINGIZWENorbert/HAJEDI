
import 'package:flutter/material.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/animated_snackbar.dart';
import 'package:hajedi/widgets/input_text_field.dart';
import 'package:hajedi/widgets/select_option.dart';
import 'package:uuid/uuid.dart';

class UserForm extends StatefulWidget {
  final User? user;
  final bool isEditMode;
  final Function(User) onUserSaved;
  // final Function(String?) onRoleChanged;

  const UserForm({
    super.key,
    this.user,
    this.isEditMode = false,
    required this.onUserSaved,
    // required this.onRoleChanged,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  // final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  late String? role;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _passwordController.text = widget.user!.password;
      role = widget.user!.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {

    final loc = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
     showAnimatedSnackBar(context, loc.please_fill_all_fields,isSuccess: false);
      return;
    }

      final user = User(
        id: widget.user?.id ?? "",
        clientId: widget.user?.clientId ?? Uuid().v4(),
        name: _nameController.text.trim(),
        role: role ?? widget.user?.role ?? '',
        password: _passwordController.text.trim()
      );

      widget.onUserSaved(user);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                loc.name,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            InputTextField(
              controller: _nameController,
              labelText: loc.name,
              hintText: 'Enter ${loc.name}',
            ),
          ],

        ),
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                loc.role,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SelectOption(
                  label: 'role',
                  options: const ['admin', 'employee'],
                  initialValue: widget.isEditMode ? role : null,
                  isEditMode: widget.isEditMode,
                  // onSelect: (value) {
                  //   setState(() {
                  //     if (value != null) {
                  //       role = value;
                  //       widget.onRoleChanged(value);
                  //     }
                  //   });
                  // }),
                  onSelect: (value) {
                      setState(() {
                        role = value ?? '';
                      });                    
                  }),
            )
          ],
        ),

        // Password Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                loc.password,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            InputTextField(
              controller: _passwordController,
              labelText: loc.password,
              hintText: '......',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.user != null
                  ? loc.update_user
                  : loc.add_new_user,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }
}