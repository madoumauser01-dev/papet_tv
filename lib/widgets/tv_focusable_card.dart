import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class TvFocusableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleMultiplier;
  final Color focusBorderColor;
  final double borderRadius;
  final FocusNode? focusNode;

  const TvFocusableCard({
    Key? key,
    required this.child,
    required this.onTap,
    this.scaleMultiplier = 1.04,
    this.focusBorderColor = AppColors.primaryGlow,
    this.borderRadius = 16,
    this.focusNode,
  }) : super(key: key);

  @override
  State<TvFocusableCard> createState() => _TvFocusableCardState();
}

class _TvFocusableCardState extends State<TvFocusableCard> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    // Only dispose if we created it locally
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        // Handle D-pad OK / Enter keys
        final isEnterKey = event.logicalKey.keyLabel == 'Enter' || event.logicalKey.keyLabel == 'Select';
        if (isEnterKey && _isFocused) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isFocused ? widget.scaleMultiplier : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: _isFocused ? widget.focusBorderColor : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.focusBorderColor.withOpacity(0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
