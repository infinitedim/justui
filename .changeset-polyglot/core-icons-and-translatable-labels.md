---
"just_ui_core": minor
---

Fix Material icons that showed the wrong glyph (the accordion and select chevrons, the select search icon, the table sort arrows and the sidebar chevron used web font codepoints). Add `JustCarousel.indicatorSemanticsLabel` and `JustDatePickerLocale.dayLabel` so screen reader labels can be translated; the defaults keep the English text. The select trigger is now one Tab stop and shows its focus ring. The accordion states its expansion through the expanded flag instead of English words, and the sidebar folder chevron points the right way in right-to-left layouts.
