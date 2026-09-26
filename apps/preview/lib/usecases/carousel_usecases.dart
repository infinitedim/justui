// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/carousel/just_carousel.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default Carousel', type: JustCarousel)
Widget buildJustCarouselDefaultUseCase(BuildContext context) {
  final bool loop = context.knobs.boolean(label: 'Loop', initialValue: true);
  final bool vertical = context.knobs.boolean(
    label: 'Vertical',
    initialValue: false,
  );
  final JustCarouselIndicator indicator = context.knobs.object
      .dropdown<JustCarouselIndicator>(
        label: 'Indicator',
        options: JustCarouselIndicator.values,
        initialOption: JustCarouselIndicator.dots,
      );
  final JustCarouselTransition transition = context.knobs.object
      .dropdown<JustCarouselTransition>(
        label: 'Transition',
        options: JustCarouselTransition.values,
        initialOption: JustCarouselTransition.slide,
      );
  final double viewportFraction = context.knobs.double.slider(
    label: 'Viewport Fraction',
    initialValue: 1.0,
    min: 0.6,
    max: 1.0,
  );

  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 480.0, maxHeight: 260.0),
    child: JustCarousel(
      loop: loop,
      orientation: vertical ? .vertical : .horizontal,
      indicator: indicator,
      transition: transition,
      viewportFraction: viewportFraction,
      children: const <Widget>[
        _CarouselSlide(label: 'Slide 1'),
        _CarouselSlide(label: 'Slide 2'),
        _CarouselSlide(label: 'Slide 3'),
        _CarouselSlide(label: 'Slide 4'),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Auto Scroll', type: JustCarousel)
Widget buildJustCarouselAutoScrollUseCase(BuildContext context) {
  final bool showArrows = context.knobs.boolean(
    label: 'Show Arrows',
    initialValue: true,
  );

  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 480.0, maxHeight: 260.0),
    child: JustCarousel(
      autoScroll: const JustCarouselAutoScroll(),
      showArrows: showArrows,
      children: const <Widget>[
        _CarouselSlide(label: 'Auto 1'),
        _CarouselSlide(label: 'Auto 2'),
        _CarouselSlide(label: 'Auto 3'),
      ],
    ),
  );
}

class _CarouselSlide extends StatelessWidget {
  final String label;

  const _CarouselSlide({required this.label});

  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    return Container(
      alignment: .center,
      color: colors.card,
      child: Text(
        label,
        style: context.justTypo.headingMd.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
