part of '../customized_keyboard.dart';

class KeyboardWrapper extends StatefulWidget {
  final Widget child;
  final bool hasBottomSheetOrDialog;
  final bool removePaddingSafe;
  final Color? colorPaddingSafe;
  final double? width;
  final List<CustomKeyboard> keyboards;

  /// Will be called before showing any keyboard.
  ///
  /// If it returns true, the requested keyboard is shown, otherwise the keyboard
  /// request is ignored.
  ///
  /// Use this to prevent keyboards showing on desktop devices for example.
  final bool Function(CustomKeyboard)? shouldShow;

  const KeyboardWrapper({
    super.key,
    required this.child,
    this.hasBottomSheetOrDialog = false,
    this.removePaddingSafe = false,
    this.colorPaddingSafe,
    this.width,
    this.keyboards = const [],
    this.shouldShow,
  });

  static KeyboardWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<KeyboardWrapperState>();
  }

  @override
  State<KeyboardWrapper> createState() => KeyboardWrapperState();
}

class KeyboardWrapperState extends State<KeyboardWrapper> with SingleTickerProviderStateMixin {
  /// Holds the active connection to a [CustomTextField]
  CustomKeyboardConnection? _keyboardConnection;

  late final AnimationController _animationController;
  late Animation<Offset> _animationPosition;
  double _bottomInset = 0.0;
  Widget? _activeKeyboard;
  double _keyboardHeight = 0;
  final _resizeHeightKeyBoard = ValueNotifier(0.0);

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _animationPosition = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.addListener(
          () => _resizeHeightKeyBoard.value = (_keyboardHeight + (widget.removePaddingSafe ? 0 : MediaQuery.of(context).padding.bottom)) * _animationController.value,
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _resizeHeightKeyBoard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.maybeOf(context) ?? MediaQueryData.fromWindow(WidgetsBinding.instance.window);

    return MediaQuery(
        // Overwrite data to apply bottom inset for customized keyboard
        // if supposed to be shown.
        data: _activeKeyboard != null
            ? data.copyWith(
                viewInsets: data.viewInsets.copyWith(bottom: _bottomInset + data.viewInsets.bottom + data.padding.bottom),
              )
            : data,
        child: Stack(children: [
          widget.hasBottomSheetOrDialog
              ? ValueListenableBuilder<double>(
              valueListenable: _resizeHeightKeyBoard,
              builder: (context, height, child) {
                return Padding(
                  padding: EdgeInsets.only(bottom: height),
                  child: widget.child, // Nội dung chính của bạn
                );
              })
              : Positioned.fill(
            child: ValueListenableBuilder<double>(
                valueListenable: _resizeHeightKeyBoard,
                builder: (context, height, child) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: height),
                    child: widget.child, // Nội dung chính của bạn
                  );
                }),
          ),
          if (_activeKeyboard != null)
            Positioned(
              bottom: 0,
              width: widget.width ?? data.size.width,
              height: (_keyboardHeight + (widget.removePaddingSafe ? 0 : MediaQuery.of(context).padding.bottom)),
              child: SlideTransition(
                position: _animationPosition,
                child: Material(
                  child: Container(
                    color: widget.colorPaddingSafe,
                    padding: EdgeInsets.only(bottom: (widget.removePaddingSafe ? 0 : MediaQuery.of(context).padding.bottom)),
                    child: _activeKeyboard,
                  ),
                ),
              ),
            )
        ]));
  }

  CustomKeyboard getKeyboardByName(String name) {
    try {
      final keyboard = widget.keyboards.firstWhere((keyboard) => keyboard.name == name);
      return keyboard;
    } on StateError {
      throw KeyboardNotRegisteredError();
    }
  }

  /// Connect with a custom keyboard
  void connect(CustomKeyboardConnection connection) {
    // Verify that the keyboard exists -> throws otherwise
    final keyboard = getKeyboardByName(connection.name);

    // Should we show this keyboard?
    if (widget.shouldShow?.call(keyboard) == false) {
      return;
    }

    // Set as active
    connection.isActive = true;

    // Is a keyboard currently shown and is it the same as the requested one?
    if (_keyboardConnection?.name == connection.name) {
      // Only change the connection to send events to the new text field, discarding the
      // old one.
      _keyboardConnection = connection;
    }
    // Is another keyboard currently shown?
    else if (_keyboardConnection != null) {
      // Hide old keyboard in an animation
      // Then animate the new keyboard in
      _animateOut().then((_) {
        _keyboardConnection = connection;
        _animateIn(keyboard: keyboard, fieldContext: connection.focusNode.context);
      });
    }
    // No keyboard shown yet?
    else {
      // Animate new keyboard in and set connection
      _keyboardConnection = connection;
      _animateIn(keyboard: keyboard, fieldContext: connection.focusNode.context);
    }
  }

  /// Animate keyboard in
  Future<void> _animateIn({required CustomKeyboard keyboard, required BuildContext? fieldContext}) {
    setState(() {
      _activeKeyboard = keyboard.build(context);
      _keyboardHeight = keyboard.height;
    });
    return _animationController.forward().then((value) {
      setState(() => _bottomInset = _keyboardHeight);

      // Ensure the currently active field is shown and not hidden by the keyboard
      // -- only if item is not visible anyways --
      if (fieldContext != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final visibilityState = isItemVisible(fieldContext);

          switch (visibilityState) {
            case VisibilityState.hiddenAbove:
              Scrollable.ensureVisible(fieldContext, alignment: 0.1);
              break;
            case VisibilityState.hiddenBelow:
              Scrollable.ensureVisible(fieldContext, alignment: 0.9);
              break;
            case VisibilityState.visible:
              // Do nothing
              break;
          }
        });
      }
    });
  }

  /// Animate keyboard out
  Future<void> _animateOut() {
    setState(() => _bottomInset = 0.0);
    return _animationController.reverse();
  }

  /// Disconnect the given connection id
  void disconnect({required String id}) {
    // Is the current connection id active?
    if (_keyboardConnection?.id == id) {
      onKey(const CustomKeyboardEvent.calculate());
      // Set as inactive
      _keyboardConnection!.isActive = false;

      // Remove it and hide the keyboard
      _keyboardConnection = null;
      // Do this after a possible build is done to prevent an exception that would
      // occur if the widget is currently rebuilding. It might be that we lost focus
      // on the textfield due to a widget rebuild.
      _animateOut();
    }

    // Otherwise, do nothing.
  }

  /// Hides the keyboard if currently shown
  void hideKeyboard() {
    // Disconnect and hide if keyboard connection is still active
    if (_keyboardConnection != null) {
      return disconnect(id: _keyboardConnection!.id);
    } else {
      // Otherwise, just animate out
      _animateOut();
    }
  }

  /// Add character to text field
  void onKey(CustomKeyboardEvent key) {
    String calculate(String text) {
      if (text.isEmpty) return '';
      var userInputFC = text.replaceAll(',', '');
      userInputFC = userInputFC.replaceAll('x', '*');
      userInputFC = userInputFC.replaceAll(':', '/');
      var last = userInputFC.substring(userInputFC.length - 1);
      while ('+-x:*/'.contains(last)) {
        userInputFC = userInputFC.substring(0, userInputFC.length - 1);
        last = userInputFC.substring(userInputFC.length - 1);
      }
      try {
        final p = Parser();
        final exp = p.parse(userInputFC);
        final ctx = ContextModel();
        final eval = exp.evaluate(EvaluationType.REAL, ctx);

        final userOutput = double.tryParse(eval.toString())?.numberFormat() ?? '';
        return userOutput;
      } catch (e) {
        return '';
      }
    }

    int countCommas(String text) {
      return text.split(',').length - 1;
    }

    String formatNumber(String number) {
      if (number.length > 16) {
        number = number.substring(0, 16);
      }
      final parsedNumber = double.tryParse(number);
      if (parsedNumber != null) {
        return parsedNumber.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
              (match) => ",",
        );
      }
      return number;
    }

    String formatExpression(String expression) {
      final regex = RegExp(r'((\d+\.)+\d+|\d+|[+\-x/])');
      final matches = regex.allMatches(expression);

      final List<String> formattedParts = [];
      for (final match in matches) {
        final part = match.group(0) ?? '';
        if (part.contains('.')) {
          final text = part.split('.');
          final f = formatNumber(text.first);
          var c1 = '';
          var c2 = '';
          try {
            c1 = text[1].substring(0, 1);
          } catch (_) {
            c1 = '';
          }
          try {
            c2 = text[1].substring(1, 2);
          } catch (_) {
            c2 = '';
          }
          formattedParts.add('$f.$c1$c2');
        } else {
          formattedParts.add(formatNumber(part));
        }
      }

      return formattedParts.join('');
    }

    void replaceSelection({TextSelection? selection, String newText = ""}) {
      final originalValue = _keyboardConnection!.controller.value;

      final selectionToUse = selection ?? originalValue.selection;

      final textBefore = selectionToUse.textBefore(originalValue.text);
      final textAfter = selectionToUse.textAfter(originalValue.text);

      final rawNewText = "$textBefore$newText$textAfter".replaceAll(',', '');

      final newFragmentText = formatExpression(rawNewText);

      final rawCursorPosition = textBefore.length + newText.length;
      int adjustedCursorPosition = rawCursorPosition;

      var commaCountBefore = countCommas(originalValue.text);
      var commaCountAfter = countCommas(newFragmentText);
      adjustedCursorPosition += (commaCountAfter - commaCountBefore);

      adjustedCursorPosition = adjustedCursorPosition.clamp(0, newFragmentText.length);

      final newValue = originalValue.copyWith(
        text: newFragmentText,
        selection: TextSelection.collapsed(offset: adjustedCursorPosition),
      );

      TextEditingValue formattedValue = newValue;
      final formatters = _keyboardConnection!.inputFormatters;
      if (formatters != null && formatters.isNotEmpty) {
        for (var formatter in formatters) {
          formattedValue = formatter.formatEditUpdate(originalValue, formattedValue);
        }
      }

      _keyboardConnection!.controller.value = formattedValue;
      _keyboardConnection!.triggerOnChanged();
    }

    void replaceSelectionNonFormat({TextSelection? selection, String newText = ""}) {
      // Remove all selected text
      final originalValue = _keyboardConnection!.controller.value;

      // Use provided selection over actual selection
      final selectionToUse = selection ?? originalValue.selection;

      // Generate new text value
      final textBefore = selectionToUse.textBefore(originalValue.text);
      final textAfter = selectionToUse.textAfter(originalValue.text);
      final newValue = originalValue.copyWith(
        text: "$textBefore$newText$textAfter",
        selection: TextSelection.collapsed(offset: selectionToUse.start + newText.length),
      );

      // Apply input formatters
      // This is not done automatically by the field because we're effectively changing
      // the value programatically.
      TextEditingValue formattedValue = newValue;
      final formatters = _keyboardConnection!.inputFormatters;
      if (formatters != null && formatters.isNotEmpty) {
        for (var formatter in formatters) {
          formattedValue = formatter.formatEditUpdate(originalValue, formattedValue);
        }
      }

      // Set new value
      _keyboardConnection!.controller.value = formattedValue;
      // Trigger onChanged event on text field
      _keyboardConnection!.triggerOnChanged();
    }

    void replaceOperator({TextSelection? selection, String newText = ""}) {
      var originalValue = _keyboardConnection!.controller.value;
      final selectionToUse = selection ?? originalValue.selection;
      var textBefore = selectionToUse.textBefore(originalValue.text);
      final textAfter = selectionToUse.textAfter(originalValue.text);
      var count = newText.length;
      if (selectionToUse.start <= 0) {
        return;
      }
      if (textAfter.isNotEmpty && '.+-x:/'.contains(textAfter.substring(0, 1))) {
        return;
      }
      if ('.+-x:/'.contains(textBefore.substring(selectionToUse.start - 1, selectionToUse.start))) {
        textBefore = textBefore.substring(0, textBefore.length - 1);
        count = 0;
      }

      // Generate new text value
      final newValue = originalValue.copyWith(
        text: "$textBefore$newText$textAfter",
        selection: TextSelection.collapsed(offset: selectionToUse.start + count),
      );

      // Apply input formatters
      // This is not done automatically by the field because we're effectively changing
      // the value programatically.
      TextEditingValue formattedValue = newValue;
      final formatters = _keyboardConnection!.inputFormatters;
      if (formatters != null && formatters.isNotEmpty) {
        for (var formatter in formatters) {
          formattedValue = formatter.formatEditUpdate(originalValue, formattedValue);
        }
      }

      // Set new value
      _keyboardConnection!.controller.value = formattedValue;

      // Trigger onChanged event on text field
      _keyboardConnection!.triggerOnChanged();
    }

    // Throw if keyboard connection not found
    // Ignore if hideKeyboard type because the field might have lost focus and disconnected
    // before this method is called. It won't hurt to call [hideKeyboard()] multiple times.
    if (_keyboardConnection == null && key.type != CustomKeyType.hideKeyboard) {
      throw KeyboardMissingConnection();
    }

    switch (key.type) {
      case CustomKeyType.character:
        replaceSelection(newText: key.value!);
        break;
      case CustomKeyType.operator:
        replaceOperator(newText: key.value!);
        break;
      case CustomKeyType.submit:
        if (_keyboardConnection!.onSubmit != null) {
          _keyboardConnection!.onSubmit!(_keyboardConnection!.controller.text);
        }
        break;
      case CustomKeyType.deleteOne:
        final orig = _keyboardConnection!.controller.value;
        if (orig.selection.start != -1) {
          // Text selected?
          if (orig.selection.start != orig.selection.end) {
            replaceSelection();
          } else if (orig.selection.start > 0) {
            // Remove last character
            replaceSelection(
              selection: TextSelection(baseOffset: orig.selection.start - 1, extentOffset: orig.selection.start),
            );
          }
        }
        break;
      case CustomKeyType.clear:
        final origText = _keyboardConnection!.controller.text;
        replaceSelection(selection: TextSelection(baseOffset: 0, extentOffset: origText.length));
        break;
      case CustomKeyType.next:
        if (_keyboardConnection!.onNext != null) {
          _keyboardConnection!.onNext!();
        } else {
          try {
            _keyboardConnection!.focusNode.nextFocus();
          } catch (e) {
            throw KeyboardErrorFocusNext(e);
          }
        }
        break;
      case CustomKeyType.previous:
        if (_keyboardConnection!.onPrev != null) {
          _keyboardConnection!.onPrev!();
        } else {
          try {
            _keyboardConnection!.focusNode.previousFocus();
          } catch (e) {
            throw KeyboardErrorFocusPrev(e);
          }
        }
        break;
      case CustomKeyType.hideKeyboard:
        hideKeyboard();
        break;

      case CustomKeyType.calculate:
        final t = calculate(_keyboardConnection!.controller.text);
        _keyboardConnection!.controller.text = t;
        if (_keyboardConnection!.onSubmit != null) {
          _keyboardConnection!.onSubmit!(t);
        }
        break;
    }
  }
}

extension DoubleExtensions on double {
  String numberFormat() {
    if (toString().endsWith('.0')) {
      return intl.NumberFormat('###,###,###,##0', 'en_US').format(this);
    } else {
      return intl.NumberFormat('###,###,###,##0.0#', 'en_US').format(this);
    }
  }
}
