use super::*;

#[test]
fn test_transpile_badge_widget() {
    let input = r#"
class JustBadge extends StatelessWidget {
  final String label;
  final JustBadgeVariant variant;

  const JustBadge({
    super.key,
    required this.label,
    this.variant = JustBadgeVariant.solid,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
"#;

    let output = transpile_to_primary_constructor(input);

    assert!(output.contains("class const JustBadge({"));
    assert!(output.contains("super.key,"));
    assert!(output.contains("required final String label,"));
    assert!(output.contains("final JustBadgeVariant variant = JustBadgeVariant.solid,"));
    assert!(output.contains("}) extends StatelessWidget {"));
    assert!(!output.contains("  const JustBadge({"));
}

#[test]
fn test_transpile_data_class() {
    let input = r#"
class JustBreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const JustBreadcrumbItem({
    required this.label,
    this.onTap,
  });
}
"#;

    let output = transpile_to_primary_constructor(input);

    assert!(output.contains("class const JustBreadcrumbItem({"));
    assert!(output.contains("required final String label,"));
    assert!(output.contains("final VoidCallback? onTap,"));
    assert!(!output.contains("  const JustBreadcrumbItem({"));
}

#[test]
fn test_transpile_complex_function_signature_field() {
    let input = r#"
class JustCarousel extends StatefulWidget {
  final List<Widget> children;
  final Widget Function(BuildContext context, Widget child, double progress)?
  transitionBuilder;

  const JustCarousel({
    super.key,
    required this.children,
    this.transitionBuilder,
  });

  @override
  State<JustCarousel> createState() => _JustCarouselState();
}
"#;

    let output = transpile_to_primary_constructor(input);

    assert!(output.contains("class const JustCarousel({"));
    assert!(output.contains("required final List<Widget> children,"));
    assert!(output.contains("final Widget Function(BuildContext context, Widget child, double progress)? transitionBuilder,"));
    assert!(!output.contains("  const JustCarousel({"));
}

#[test]
fn test_transpile_generic_class() {
    let input = r#"
class JustDropdown<T> extends StatelessWidget {
  final List<T> items;
  final ValueChanged<T?>? onChanged;

  const JustDropdown({
    super.key,
    required this.items,
    this.onChanged,
  });
}
"#;

    let output = transpile_to_primary_constructor(input);

    assert!(output.contains("class const JustDropdown<T>({"));
    assert!(output.contains("required final List<T> items,"));
    assert!(output.contains("final ValueChanged<T?>? onChanged,"));
    assert!(output.contains("}) extends StatelessWidget {"));
}

#[test]
fn test_transpile_string_with_comma_in_default() {
    let input = r#"
class Greeter extends StatelessWidget {
  final String greeting;

  const Greeter({
    super.key,
    this.greeting = 'Hello, world!',
  });
}
"#;

    let output = transpile_to_primary_constructor(input);

    assert!(output.contains("class const Greeter({"));
    assert!(output.contains("final String greeting = 'Hello, world!',"));
    assert!(!output.contains("world!'\n"));
}

#[test]
fn test_local_variable_with_same_name_not_removed() {
    let input = r#"
class CounterWidget extends StatelessWidget {
  final int count;

  const CounterWidget({
    super.key,
    required this.count,
  });

  void helper() {
    final int count = 10;
  }
}
"#;

    let output = transpile_to_primary_constructor(input);

    assert!(output.contains("class const CounterWidget({"));
    assert!(output.contains("required final int count,"));
    assert!(output.contains("final int count = 10;"));
}

#[test]
fn test_class_instantiation_in_method_not_confused_for_constructor() {
    let input = r#"
class Item extends StatelessWidget {
  final String title;

  const Item({
    super.key,
    required this.title,
  });

  static List<Item> makeList() {
    return [
      Item(title: 'A'),
      Item(title: 'B'),
    ];
  }
}
"#;

    let output = transpile_to_primary_constructor(input);

    assert!(output.contains("class const Item({"));
    assert!(output.contains("required final String title,"));
    assert!(output.contains("Item(title: 'A')"));
}

#[test]
fn test_fail_safe_on_initializer_assert() {
    let input = r#"
class TimePickerSpinner extends StatefulWidget {
  final int minuteInterval;

  const TimePickerSpinner({
    super.key,
    this.minuteInterval = 1,
  }) : assert(60 % minuteInterval == 0, 'must divide 60');

  @override
  State<TimePickerSpinner> createState() => _TimePickerSpinnerState();
}
"#;

    let output = transpile_to_primary_constructor(input);
    assert_eq!(input, output);
}

#[test]
fn test_fail_safe_on_multiple_generative_constructors() {
    let input = r#"
class JustSlider extends StatefulWidget {
  final double? value;
  final JustRangeValues? rangeValues;

  const JustSlider({
    super.key,
    required this.value,
  }) : rangeValues = null;

  const JustSlider.range({
    super.key,
    required this.rangeValues,
  }) : value = null;
}
"#;

    let output = transpile_to_primary_constructor(input);
    assert_eq!(input, output);
}

#[test]
fn test_sibling_class_fields_preserved() {
    let input = r#"
class TimePickerDial extends StatelessWidget {
  final TimeOfDay value;

  const TimePickerDial({
    super.key,
    required this.value,
  });
}

class _ClockFacePainter extends CustomPainter {
  final double radius;
  final Color color;

  _ClockFacePainter({
    required this.radius,
    required this.color,
  });
}
"#;

    let output = transpile_to_primary_constructor(input);

    assert!(output.contains("class const TimePickerDial({"));
    assert!(output.contains("required final TimeOfDay value,"));
    // _ClockFacePainter should retain its fields
    assert!(output.contains("class _ClockFacePainter({"));
    assert!(output.contains("required final double radius,"));
    assert!(output.contains("required final Color color,"));
}

#[test]
fn test_transpile_fail_safe_unmatched_code() {
    let input = "class CustomWidget {}";
    let output = transpile_to_primary_constructor(input);
    assert_eq!(input, output);
}

#[test]
fn test_standard_named_params_with_docs_defaults_and_super() {
    let input = r#"/// Doc for the widget.
class const JustThing({
  super.key,

  /// The label.
  required final String label,
  final bool enabled = true,
  final void Function(int)? onChanged,
  required super.child,
}) extends InheritedWidget {
  @override
  bool updateShouldNotify(JustThing old) => label != old.label;
}
"#;
    let expected = r#"/// Doc for the widget.
class JustThing extends InheritedWidget {
  /// The label.
  final String label;

  final bool enabled;

  final void Function(int)? onChanged;

  const JustThing({
    super.key,
    required this.label,
    this.enabled = true,
    this.onChanged,
    required super.child,
  });

  @override
  bool updateShouldNotify(JustThing old) => label != old.label;
}
"#;
    let (output, skipped) = transpile_to_standard_constructor(input);
    assert!(skipped.is_empty());
    assert_eq!(output, expected);
}

#[test]
fn test_standard_positional_semicolon_body_and_generic() {
    let input = "class const Pair(\n  final int a,\n  final int b,\n);\n\nfinal class const Holder<T extends Object>({required final T value}) {}\n";
    let expected = "class Pair {\n  final int a;\n  final int b;\n\n  const Pair(\n    this.a,\n    this.b,\n  );\n}\n\nfinal class Holder<T extends Object> {\n  final T value;\n\n  const Holder({\n    required this.value,\n  });\n}\n";
    let (output, skipped) = transpile_to_standard_constructor(input);
    assert!(skipped.is_empty());
    assert_eq!(output, expected);
}

#[test]
fn test_standard_rewrites_new_constructors_only_at_member_level() {
    let input = r#"class const Tabs({final int index = 0}) extends StatelessWidget {
  const new pill({int index = 0}) : this(index: index);

  Widget build(BuildContext context) {
    final x =
        new Foo();
    return x;
  }
}

class Plain {
  const Plain();
  factory new empty() => const Plain();
}
"#;
    let (output, skipped) = transpile_to_standard_constructor(input);
    assert!(skipped.is_empty());
    assert!(output.contains("  const Tabs.pill({int index = 0}) : this(index: index);"));
    assert!(output.contains("        new Foo();"));
    assert!(output.contains("  factory Plain.empty() => const Plain();"));
    assert!(!output.contains("class const"));
}

#[test]
fn test_standard_skips_unsupported_params_and_keeps_conventional_classes() {
    let input = "class const Odd(int plain) {}\n\nclass Normal {\n  const Normal();\n}\n";
    let (output, skipped) = transpile_to_standard_constructor(input);
    assert_eq!(skipped, vec!["Odd".to_string()]);
    assert_eq!(output, input);
}

#[test]
fn test_apply_dart_target_round_trip() {
    let primary = "class const Chip({\n  super.key,\n  required final String label,\n}) extends StatelessWidget {}\n";
    let standard = apply_dart_target(primary, DartTarget::Standard);
    assert!(standard.contains("const Chip({"));
    let back = apply_dart_target(&standard, DartTarget::Primary);
    assert!(back.contains("class const Chip({"));
    assert!(back.contains("required final String label,"));
    assert_eq!(apply_dart_target(primary, DartTarget::Primary), primary);
}
