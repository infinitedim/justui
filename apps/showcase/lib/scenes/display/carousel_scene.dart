// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/card/just_card.dart';
import 'package:just_ui_core/src/components/card/just_card_style.dart';
import 'package:just_ui_core/src/components/carousel/just_carousel.dart';

import '../scene.dart';
import 'display_look.dart';

const int _total = 3;

/// Room around each slide for its shadow: the page view clips at its edge.
const EdgeInsets _shadowRoom = EdgeInsets.fromLTRB(12, 4, 12, 14);

/// Part 09, carousel: one 200 x 72 slide on a surface and a row of dots
/// below it, like `KitPart` `carousel`.
///
/// No autoplay and no loop; the first slide shows. The carousel takes focus
/// as one stop (Tab in, Tab out) and the arrow keys change the slide; the
/// dots also respond to a tap, as the React dots do to a click, and are
/// named from the page's `slideAria`, like the React dots.
Widget carouselScene(BuildContext context, SceneContext scene) {
  final DisplayLook look = DisplayLook.of(context);
  final String template = scene.strings.text('slide');
  return Semantics(
    container: true,
    label: scene.strings.text('slidesLabel'),
    child: SizedBox(
      width: 200 + _shadowRoom.horizontal,
      height: 72 + _shadowRoom.vertical + 26,
      child: JustCarousel(
        loop: false,
        indicator: .dots,
        indicatorPosition: .outside,
        indicatorSemanticsLabel: scene.strings.text('slideAria'),
        transition: .none,
        style: JustCarouselStyle(
          indicatorSize: 10,
          activeIndicatorSize: 10,
          indicatorSpacing: 6,
          indicatorColor: look.bold ? look.roles.surface : null,
        ),
        children: <Widget>[
          for (int index = 1; index <= _total; index++)
            _slide(look, slideLabel(template, index, _total)),
        ],
      ),
    ),
  );
}

/// [template] with `{index}` and `{total}` filled, like the docs'
/// `formatMessage`.
String slideLabel(String template, int index, int total) =>
    template.replaceAll('{index}', '$index').replaceAll('{total}', '$total');

/// A slide: a surface card filling its page. Core's card ignores its
/// `padding` argument, so the zero padding goes in through the style; the
/// neobrutalism outline sits inside the 72 px.
Widget _slide(DisplayLook look, String label) {
  return Padding(
    padding: _shadowRoom,
    child: JustCard(
      style: const JustCardStyle(padding: EdgeInsets.zero),
      child: SizedBox(
        height: look.bold ? 72 - 2 * look.line : 72,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: .w600),
          ),
        ),
      ),
    ),
  );
}
