import 'package:flutter/material.dart';

void showAnimatedSnackBar(BuildContext context, String message,
    {bool isSuccess = true, OverlayState? overlayState}) {
  final overlay = overlayState ?? Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _AnimatedSnackBar(
      message: message,
      isSuccess: isSuccess,
      onDismiss: () {
        overlayEntry.remove();
      },
    ),
  );

  overlay.insert(overlayEntry);
}

class _AnimatedSnackBar extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback onDismiss;

  const _AnimatedSnackBar({
    required this.message,
    required this.isSuccess,
    required this.onDismiss,
  });

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Entrance: Slide up from bottom with easeOutBack
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 2.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (_isExiting) return;
    setState(() {
      _isExiting = true;
    });

    // Exit: Slide to right
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(1.5, 0.0), // Slide off to right
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Also fade out slightly during exit
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward(from: 0.0).then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 20.0,
      right: 20.0,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 17.0),
              decoration: BoxDecoration(
                color: widget.isSuccess
                    ? Theme.of(context).cardColor
                    : const Color.fromARGB(255, 228, 48, 36).withOpacity(1),
                // color: const Color.fromARGB(255, 36, 177, 41).withOpacity(1.0),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16.0,
                    offset: Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  // color: widget.isSuccess
                  //     ? (Theme.of(context).primaryColor).withOpacity(0.3)
                  //     : Colors.red.withOpacity(0.3),
                  color: Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Container(
                  //   padding: const EdgeInsets.all(8),
                  //   decoration: BoxDecoration(
                  //     color: widget.isSuccess
                  //         ? Theme.of(context).primaryColor.withOpacity(0.1)
                  //         : Colors.red.withOpacity(0.1),
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: Icon(
                  //     widget.isSuccess ? IconlyBold.tick_square : IconlyBold.danger,
                  //     color: widget.isSuccess
                  //         ? Theme.of(context).primaryColor
                  //         : Colors.red,
                  //     size: 24,
                  //   ),
                  // ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            // fontWeight: FontWeight.w600,
                            color: !widget.isSuccess ? Colors.white : null,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _dismiss,
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: !widget.isSuccess
                          ? Colors.white
                          : Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
