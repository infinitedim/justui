import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../../shared/default/_shared_tokens.dart';
import '../../shared/default/_shared_theme_provider.dart';
import 'just_input_style.dart';
import 'just_input_variants.dart';

/// A highly customizable, theme-aware text input field supporting multiple variants and states.
class JustInput extends StatefulWidget {
  /// The descriptive label text. Sits inside when idle, floats to top when active.
  final String? label;

  /// Input placeholder placeholder shown when field is empty.
  final String? hint;

  /// A helper caption displayed below the input.
  final String? helper;

  /// Error text. If non-null, puts the input into error state.
  final String? errorText;

  /// Success text. If non-null, puts the input into success state.
  final String? successText;

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Controls the keyboard focus.
  final FocusNode? focusNode;

  /// Callback when the input value changes.
  final ValueChanged<String>? onChanged;

  /// Callback when user submits input (e.g. presses enter).
  final ValueChanged<String>? onSubmitted;

  /// Callback when user taps the input.
  final VoidCallback? onTap;

  /// A validator function compatible with standard [Form].
  final FormFieldValidator<String>? validator;

  /// Custom prefix widget placed before the text input.
  final Widget? prefix;

  /// Custom suffix widget placed after the text input.
  final Widget? suffix;

  /// Shorthand icon data for prefix.
  final IconData? prefixIcon;

  /// Shorthand icon data for suffix.
  final IconData? suffixIcon;

  /// The maximum number of characters allowed.
  final int? maxLength;

  /// The maximum number of lines. Default is 1.
  final int? maxLines;

  /// The minimum number of lines.
  final int? minLines;

  /// Whether to obscure the input text (e.g. passwords).
  final bool obscureText;

  /// Whether the input is interactive.
  final bool enabled;

  /// Whether the input is read-only.
  final bool readOnly;

  /// Whether to autofocus this field.
  final bool autofocus;

  /// The type of keyboard to display.
  final TextInputType? keyboardType;

  /// The action to display on the keyboard.
  final TextInputAction? textInputAction;

  /// Formatters applied as text is typed.
  final List<TextInputFormatter>? inputFormatters;

  /// The visual size classification.
  final JustInputSize size;

  /// Per-instance style overrides.
  final JustInputStyle? style;

  /// The variant format.
  final JustInputVariant variant;

  /// The length of code for OTP input (applicable only when variant is otp).
  final int? otpLength;

  /// Whether to display a clear button when the input is filled.
  final bool showClearButton;

  /// Default constructor for [JustInput].
  const JustInput({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.successText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.size = .md,
    this.style,
    this.showClearButton = false,
  }) : variant = .text,
       otpLength = null;

  /// Named constructor for password inputs. Includes visibility eye toggle.
  const JustInput.password({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.successText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.prefix,
    this.prefixIcon,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textInputAction,
    this.size = .md,
    this.style,
    this.showClearButton = false,
  }) : variant = .password,
       maxLines = 1,
       minLines = null,
       obscureText = true,
       suffix = null,
       suffixIcon = null,
       keyboardType = .visiblePassword,
       inputFormatters = null,
       otpLength = null;

  /// Named constructor for search inputs. Includes search icon and clear button.
  ///
  /// By default, [showClearButton] is set to `true` specifically for this variant,
  /// matching the standard user experience convention for search fields.
  const JustInput.search({
    super.key,
    this.label,
    this.hint = 'Search...',
    this.helper,
    this.errorText,
    this.successText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.suffix,
    this.suffixIcon,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textInputAction = .search,
    this.size = .md,
    this.style,
    this.showClearButton = true,
  }) : variant = .search,
       maxLines = 1,
       minLines = null,
       obscureText = false,
       prefix = null,
       prefixIcon = null,
       keyboardType = .text,
       inputFormatters = null,
       otpLength = null;

  /// Named constructor for numeric inputs. Includes stepper buttons (+/-).
  const JustInput.number({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.successText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textInputAction,
    this.size = .md,
    this.style,
    this.showClearButton = false,
  }) : variant = .number,
       maxLines = 1,
       minLines = null,
       obscureText = false,
       keyboardType = const .numberWithOptions(decimal: true, signed: true),
       inputFormatters = null,
       otpLength = null;

  /// Named constructor for multi-line textareas. Auto-expands up to [maxLines] (default: 5) and scrolls afterwards.
  const JustInput.textarea({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.successText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 5,
    this.minLines = 3,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textInputAction,
    this.size = .md,
    this.style,
    this.showClearButton = false,
  }) : variant = .textarea,
       obscureText = false,
       keyboardType = .multiline,
       inputFormatters = null,
       otpLength = null;

  /// Named constructor for segmented OTP inputs. Auto-advances focus and supports paste distribution.
  const JustInput.otp({
    super.key,
    required int length,
    this.errorText,
    this.successText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.size = .md,
    this.style,
  }) : variant = .otp,
       otpLength = length,
       label = null,
       hint = null,
       helper = null,
       onSubmitted = null,
       onTap = null,
       validator = null,
       prefix = null,
       suffix = null,
       prefixIcon = null,
       suffixIcon = null,
       maxLength = 1,
       maxLines = 1,
       minLines = null,
       obscureText = false,
       readOnly = false,
       keyboardType = .number,
       inputFormatters = null,
       textInputAction = null,
       showClearButton = false;

  @override
  State<JustInput> createState() => _JustInputState();
}

class _JustInputState extends State<JustInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  final ValueNotifier<bool> _isFocused = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isFilled = ValueNotifier<bool>(false);

  // Password visibility state
  final ValueNotifier<bool> _isPasswordObscured = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(_handleFocusChanged);
    _controller.addListener(_handleTextChanged);

    _isFilled.value = _controller.text.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant JustInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleTextChanged);
      if (widget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_handleTextChanged);
      _isFilled.value = _controller.text.isNotEmpty;
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChanged);
      _isFocused.value = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _controller.removeListener(_handleTextChanged);

    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    _isFocused.dispose();
    _isFilled.dispose();
    _isPasswordObscured.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    _isFocused.value = _focusNode.hasFocus;
  }

  void _handleTextChanged() {
    _isFilled.value = _controller.text.isNotEmpty;
  }

  void _handleIncrement() {
    if (!widget.enabled || widget.readOnly) return;
    final double val = .tryParse(_controller.text) ?? 0.0;
    final updated = val + 1.0;
    // Format appropriately
    _controller.text = updated % 1 == 0
        ? updated.toInt().toString()
        : updated.toString();
    widget.onChanged?.call(_controller.text);
  }

  void _handleDecrement() {
    if (!widget.enabled || widget.readOnly) return;
    final double val = .tryParse(_controller.text) ?? 0.0;
    final updated = val - 1.0;
    _controller.text = updated % 1 == 0
        ? updated.toInt().toString()
        : updated.toString();
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == .otp) {
      return _OtpInputRow(
        length: widget.otpLength ?? 6,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        size: widget.size,
        style: widget.style,
        errorText: widget.errorText,
        successText: widget.successText,
        onChanged: widget.onChanged,
        controller: _controller,
      );
    }

    final theme = JustThemeProvider.of(context).theme;
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final animations = theme.animations;

    // Dimensions based on size
    double fieldHeight;
    double fontSize;
    double paddingV;
    final double paddingH = spacing.md; // 12px
    final BorderRadius defaultRadius = .all(theme.radius.md);

    switch (widget.size) {
      case .sm:
        fieldHeight = widget.maxLines != null && widget.maxLines! > 1
            ? 80.0
            : 36.0;
        fontSize = 13.0;
        paddingV = spacing.xs; // 4px
        break;
      case .md:
        fieldHeight = widget.maxLines != null && widget.maxLines! > 1
            ? 110.0
            : 44.0;
        fontSize = 14.0;
        paddingV = spacing.sm; // 8px
        break;
      case .lg:
        fieldHeight = widget.maxLines != null && widget.maxLines! > 1
            ? 140.0
            : 52.0;
        fontSize = 16.0;
        paddingV = spacing.md; // 12px
        break;
    }

    // Custom styles
    final finalBg =
        widget.style?.backgroundColor ??
        (widget.readOnly
            ? colors.background.withValues(alpha: 0.5)
            : colors.background);
    final finalRadius = widget.style?.borderRadius ?? defaultRadius;
    final finalTextStyle =
        widget.style?.textStyle ??
        typography.bodyMd.copyWith(
          fontSize: fontSize,
          color: colors.textPrimary,
        );
    final finalLabelStyle =
        widget.style?.labelStyle ??
        typography.bodySm.copyWith(color: colors.textSecondary);
    final finalHelperStyle =
        widget.style?.helperStyle ??
        typography.caption.copyWith(color: colors.textSecondary);
    final finalPadding =
        widget.style?.contentPadding ??
        .symmetric(horizontal: paddingH, vertical: paddingV);

    // Resolve state colors
    final defaultBorder = colors.borderDefault;
    final focusedBorder = colors.borderFocus;
    final errorBorder = colors.borderError;
    final successBorder = colors.success;

    // Accessibility targets
    final bool needsMinTargetSize =
        fieldHeight < 48.0 && (widget.maxLines == null || widget.maxLines == 1);

    final bool hasSubElements =
        widget.errorText != null ||
        widget.successText != null ||
        widget.helper != null;
    final bool hasCounter = widget.maxLength != null;

    // Error announcement
    if (widget.errorText != null) {
      // ignore: deprecated_member_use
      SemanticsService.announce(widget.errorText!, .ltr);
    }

    return Semantics(
      label: widget.label,
      hint: widget.hint,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: needsMinTargetSize ? 48.0 : fieldHeight,
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isFocused,
              builder: (context, isFocused, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _isFilled,
                  builder: (context, isFilled, _) {
                    Color border = widget.style?.borderColor ?? defaultBorder;
                    if (widget.errorText != null) {
                      border = widget.style?.errorBorderColor ?? errorBorder;
                    } else if (widget.successText != null) {
                      border = successBorder;
                    } else if (isFocused) {
                      border =
                          widget.style?.focusedBorderColor ?? focusedBorder;
                    }

                    // Generate Prefix Widget
                    Widget? leadingWidget;
                    if (widget.prefixIcon != null) {
                      leadingWidget = Padding(
                        padding: .only(right: spacing.sm),
                        child: Icon(
                          widget.prefixIcon,
                          size: fontSize + 4,
                          color: colors.textSecondary,
                        ),
                      );
                    } else if (widget.prefix != null) {
                      leadingWidget = Padding(
                        padding: .only(right: spacing.sm),
                        child: widget.prefix,
                      );
                    }

                    // Generate Suffix Widget
                    Widget? trailingWidget;
                    if (widget.variant == .password) {
                      trailingWidget = ValueListenableBuilder<bool>(
                        valueListenable: _isPasswordObscured,
                        builder: (context, obscured, _) {
                          return GestureDetector(
                            onTap: () {
                              if (widget.enabled) {
                                _isPasswordObscured.value = !obscured;
                              }
                            },
                            child: Padding(
                              padding: .only(left: spacing.sm),
                              child: Icon(
                                obscured
                                    ? const IconData(
                                        0xe900,
                                      ) /* eye placeholder / person fallback */
                                    : const IconData(0xe901),
                                size: fontSize + 4,
                                color: colors.textSecondary,
                              ),
                            ),
                          );
                        },
                      );
                    } else if (widget.variant == .number) {
                      trailingWidget = Row(
                        mainAxisSize: .min,
                        children: [
                          GestureDetector(
                            onTap: _handleDecrement,
                            child: Padding(
                              padding: .symmetric(horizontal: spacing.xxs),
                              child: Icon(
                                const IconData(0xe903) /* minus fallback */,
                                size: fontSize + 2,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _handleIncrement,
                            child: Padding(
                              padding: .symmetric(horizontal: spacing.xxs),
                              child: Icon(
                                const IconData(0xe904) /* plus fallback */,
                                size: fontSize + 2,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (widget.showClearButton) {
                      trailingWidget = ValueListenableBuilder<bool>(
                        valueListenable: _isFilled,
                        builder: (context, filled, _) {
                          if (!filled) {
                            if (widget.suffixIcon != null) {
                              return Padding(
                                padding: .only(left: spacing.sm),
                                child: Icon(
                                  widget.suffixIcon,
                                  size: fontSize + 4,
                                  color: colors.textSecondary,
                                ),
                              );
                            } else if (widget.suffix != null) {
                              return Padding(
                                padding: .only(left: spacing.sm),
                                child: widget.suffix,
                              );
                            }
                            return const SizedBox.shrink();
                          }
                          return GestureDetector(
                            onTap: () {
                              if (widget.enabled) {
                                _controller.clear();
                                widget.onChanged?.call('');
                              }
                            },
                            child: Padding(
                              padding: .only(left: spacing.sm),
                              child: Icon(
                                const IconData(0xe902) /* close fallback */,
                                size: fontSize + 2,
                                color: colors.textSecondary,
                              ),
                            ),
                          );
                        },
                      );
                    } else if (widget.suffixIcon != null) {
                      trailingWidget = Padding(
                        padding: .only(left: spacing.sm),
                        child: Icon(
                          widget.suffixIcon,
                          size: fontSize + 4,
                          color: colors.textSecondary,
                        ),
                      );
                    } else if (widget.suffix != null) {
                      trailingWidget = Padding(
                        padding: .only(left: spacing.sm),
                        child: widget.suffix,
                      );
                    }

                    // Floating label calculations
                    final bool showLabel = widget.label != null;
                    final bool isFloating = isFocused || isFilled;

                    final labelStyle = isFloating
                        ? finalLabelStyle.copyWith(
                            fontSize: fontSize - 2,
                            color: widget.errorText != null
                                ? errorBorder
                                : (isFocused
                                      ? focusedBorder
                                      : colors.textSecondary),
                          )
                        : finalLabelStyle.copyWith(fontSize: fontSize);

                    // Compute text area / normal text field constraints
                    Widget textInput;
                    if (widget.variant == .password) {
                      textInput = ValueListenableBuilder<bool>(
                        valueListenable: _isPasswordObscured,
                        builder: (context, obscured, _) {
                          return _buildNativeTextField(
                            obscured,
                            finalTextStyle,
                            fontSize,
                          );
                        },
                      );
                    } else {
                      textInput = _buildNativeTextField(
                        widget.obscureText,
                        finalTextStyle,
                        fontSize,
                      );
                    }

                    // Label animation wrapper
                    final fieldContent = Row(
                      crossAxisAlignment:
                          widget.maxLines != null && widget.maxLines! > 1
                          ? .start
                          : .center,
                      children: [
                        ?leadingWidget,
                        Expanded(
                          child: Stack(
                            clipBehavior: .none,
                            alignment: .centerLeft,
                            children: [
                              // Floating / Idle Label
                              if (showLabel)
                                AnimatedPositioned(
                                  duration: animations.fast,
                                  curve: animations.defaultCurve,
                                  top: isFloating
                                      ? -paddingV - (fontSize / 2) - 4
                                      : 0.0,
                                  left: 0.0,
                                  child: IgnorePointer(
                                    child: AnimatedDefaultTextStyle(
                                      style: labelStyle,
                                      duration: animations.fast,
                                      curve: animations.defaultCurve,
                                      child: Text(widget.label!),
                                    ),
                                  ),
                                ),
                              // The actual Native TextField
                              Padding(
                                padding: .only(
                                  top: showLabel && isFloating
                                      ? spacing.xs
                                      : 0.0,
                                ),
                                child: textInput,
                              ),
                            ],
                          ),
                        ),
                        ?trailingWidget,
                      ],
                    );

                    final isNeobrutalism = true;
                    final double borderWidth = isNeobrutalism
                        ? 2.5
                        : (isFocused ? 2.0 : 1.0);
                    final Color finalBorderColor = isNeobrutalism
                        ? colors.textPrimary
                        : border;
                    final List<BoxShadow>? resolvedShadows = isNeobrutalism
                        ? theme.shadows.sm
                        : null;

                    return AnimatedContainer(
                      duration: isNeobrutalism
                          ? theme.animations.instant
                          : theme.animations.fast,
                      curve: animations.defaultCurve,
                      alignment: .centerLeft,
                      padding: finalPadding,
                      decoration: BoxDecoration(
                        color: finalBg,
                        borderRadius: finalRadius,
                        border: .all(
                          color: finalBorderColor,
                          width: borderWidth,
                        ),
                        boxShadow: resolvedShadows,
                      ),
                      child: fieldContent,
                    );
                  },
                );
              },
            ),
          ),
          // Sub-elements (Error, Success, Helper texts & Character Counter)
          if (hasSubElements || hasCounter) ...[
            SizedBox(height: spacing.xs),
            Row(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .start,
              children: [
                if (hasSubElements)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        String text;
                        Color textColor;
                        if (widget.errorText != null) {
                          text = widget.errorText!;
                          textColor = errorBorder;
                        } else if (widget.successText != null) {
                          text = widget.successText!;
                          textColor = successBorder;
                        } else {
                          text = widget.helper!;
                          textColor = colors.textSecondary;
                        }
                        return Text(
                          text,
                          style: finalHelperStyle.copyWith(color: textColor),
                        );
                      },
                    ),
                  )
                else
                  const Spacer(),
                if (hasCounter)
                  Padding(
                    padding: .only(left: spacing.sm),
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _controller,
                      builder: (context, value, _) {
                        return Text(
                          '${value.text.length} / ${widget.maxLength}',
                          style: finalHelperStyle.copyWith(
                            color: colors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNativeTextField(
    bool obscure,
    TextStyle textStyle,
    double fontSize,
  ) {
    final theme = JustThemeProvider.of(context).theme;
    return EditableText(
      controller: _controller,
      focusNode: _focusNode,
      obscureText: obscure,
      obscuringCharacter: '•',
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType ?? .text,
      textInputAction: widget.textInputAction,
      style: textStyle,
      cursorColor:
          widget.style?.focusedBorderColor ??
          (true ? theme.colors.textPrimary : JustColorPalette.primary500),
      backgroundCursorColor: const Color(0xFF888888),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
    );
  }
}

/// A segmented OTP input row that automatically shifts focus.
class _OtpInputRow extends StatefulWidget {
  final int length;
  final bool enabled;
  final bool autofocus;
  final JustInputSize size;
  final JustInputStyle? style;
  final String? errorText;
  final String? successText;
  final ValueChanged<String>? onChanged;
  final TextEditingController controller;

  const _OtpInputRow({
    required this.length,
    required this.enabled,
    required this.autofocus,
    required this.size,
    this.style,
    this.errorText,
    this.successText,
    this.onChanged,
    required this.controller,
  });

  @override
  State<_OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<_OtpInputRow> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    // Initialize values from controller if pre-populated
    final initial = widget.controller.text;
    for (int i = 0; i < widget.length; i++) {
      if (i < initial.length) {
        _controllers[i].text = initial[i];
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _updateValue() {
    final code = _controllers.map((c) => c.text).join();
    widget.controller.text = code;
    widget.onChanged?.call(code);
  }

  void _handlePaste(String text, int startIndex) {
    final cleanText = text.replaceAll(RegExp(r'\D'), ''); // Numbers only
    int fillIndex = startIndex;
    for (int i = 0; i < cleanText.length; i++) {
      if (fillIndex < widget.length) {
        _controllers[fillIndex].text = cleanText[i];
        fillIndex++;
      }
    }
    _updateValue();
    final targetFocus = fillIndex < widget.length
        ? fillIndex
        : widget.length - 1;
    _focusNodes[targetFocus].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final spacing = theme.spacing;

    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            for (int i = 0; i < widget.length; i++) ...[
              if (i > 0) SizedBox(width: spacing.sm),
              Expanded(
                child: KeyboardListener(
                  focusNode: FocusNode(
                    skipTraversal: true,
                  ), // Intermediate node to intercept backspace keys
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace) {
                      if (_controllers[i].text.isEmpty && i > 0) {
                        _focusNodes[i - 1].requestFocus();
                        _controllers[i - 1].clear();
                        _updateValue();
                      }
                    }
                  },
                  child: Focus(
                    onKeyEvent: (node, event) {
                      return KeyEventResult.ignored;
                    },
                    child: JustInput(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      enabled: widget.enabled,
                      autofocus: i == 0 && widget.autofocus,
                      maxLength: 1,
                      keyboardType: .number,
                      size: widget.size,
                      style: widget.style,
                      errorText: widget.errorText != null
                          ? ''
                          : null, // Color red but no text label
                      successText: widget.successText != null ? '' : null,
                      onChanged: (val) {
                        if (val.length > 1) {
                          // Handle Paste
                          _handlePaste(val, i);
                          return;
                        }

                        _updateValue();

                        if (val.isNotEmpty && i < widget.length - 1) {
                          _focusNodes[i + 1].requestFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (widget.errorText != null || widget.successText != null) ...[
          SizedBox(height: spacing.xs),
          Text(
            widget.errorText ?? widget.successText!,
            style: typographyThemeFallback(context).copyWith(
              color: widget.errorText != null
                  ? theme.colors.error
                  : theme.colors.success,
            ),
          ),
        ],
      ],
    );
  }

  TextStyle typographyThemeFallback(BuildContext context) {
    return JustThemeProvider.of(context).theme.typography.caption;
  }
}

/// A wrapper for [JustInput] to make it compatible with standard Flutter [Form].
class JustFormInput extends FormField<String> {
  /// Creates a [JustFormInput] validator field.
  JustFormInput({
    super.key,
    super.validator,
    super.initialValue,
    super.onSaved,
    super.enabled = true,
    // Forward params to JustInput
    String? label,
    String? hint,
    String? helper,
    TextEditingController? controller,
    FocusNode? focusNode,
    JustInputSize size = .md,
    JustInputStyle? style,
    JustInputVariant variant = .text,
  }) : super(
         builder: (FormFieldState<String> field) {
           void handleChanged(String val) {
             field.didChange(val);
           }

           return JustInput(
             label: label,
             hint: hint,
             helper: helper,
             errorText: field.errorText,
             controller: controller,
             focusNode: focusNode,
             enabled: field.widget.enabled,
             onChanged: handleChanged,
             size: size,
             style: style,
           );
         },
       );
}
