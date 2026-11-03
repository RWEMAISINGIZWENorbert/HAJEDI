import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
// import 'package:hajedi/components/ui/app_search_bar.dart';

class AppBarComponent extends StatefulWidget implements PreferredSizeWidget {
  final Widget? icon;
  final String title;
  final List<Widget>? actions;
  final bool isSearchable;
  final Function(String)? onSearchChanged;
  final String? hintText;

  const AppBarComponent({
    super.key,
    this.icon,
    required this.title,
    this.actions,
    this.isSearchable = false,
    this.onSearchChanged,
    this.hintText,
  });

  @override
  State<AppBarComponent> createState() => _AppBarComponentState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarComponentState extends State<AppBarComponent> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        return  AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: _isSearching ? null : widget.icon,
            title: _isSearching
            ///////////////// COMING SOON //////////////////
                // ?
                // AppSearchBar(
                //     hintText: widget.hintText,
                //     controller: _searchController,
                //     onChanged: (val) => widget.onSearchChanged?.call(val),
                //     onCancel: () {
                //       setState(() {
                //         _isSearching = false;
                //         _searchController.clear();
                //         widget.onSearchChanged?.call('');
                //       });
                //     },
                //   )
                 ? const SizedBox()
                : Text(widget.title,
                    style: Theme.of(context).textTheme.titleMedium),
            actions: _isSearching
                ? []
                : [
                    if (widget.isSearchable)
                      IconButton(
                        icon: const Icon(IconlyLight.search, size: 22),
                        onPressed: () => setState(() => _isSearching = true),
                      ),
                    ...?widget.actions,
                  ],
          );
    //     );
    //   },
    // );
  }
}
