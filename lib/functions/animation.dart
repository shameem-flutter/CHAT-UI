import 'package:flutter/material.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final InputDecoration? decoration;
  final Color blinkColor;
  final Duration blinkDuration;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const AnimatedTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.decoration,
    this.blinkColor = const Color.fromARGB(239, 239, 239, 255),
    this.blinkDuration = const Duration(milliseconds: 1500),
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  }) : super(key: key);

  @override
  _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Color?> _fillColorAnimation;
  late final FocusNode _focusNode;
  Color? _defaultFillColor;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.blinkDuration,
    );
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _defaultFillColor =
        widget.decoration?.fillColor ?? Theme.of(context).colorScheme.surface;
    _initializeColorAnimation();
  }

  void _initializeColorAnimation() {
    _fillColorAnimation =
        ColorTween(
          begin: _defaultFillColor,
          end: widget.blinkColor.withOpacity(0.3),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          decoration:
              (widget.decoration ??
                      InputDecoration(
                        hintText: widget.hintText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ))
                  .copyWith(filled: true, fillColor: _fillColorAnimation.value),
        );
      },
    );
  }
}
