# Original User Request

## Follow-up — 2026-07-01T05:24:32Z

Rebuild the Flutter Showcase Web app from a static grid to a smooth, infinite horizontal marquee using AnimationController. Update the Next.js docs homepage layout to position the marquee full-width below the centered hero section.

Working directory: /home/yourblooo/development/justui
Integrity mode: development

## Requirements

### R1. Rebuild Showcase Flutter Web into Infinite Horizontal Marquee
Implement `ShowcaseMarquee` in [showcase_marquee.dart](file:///home/yourblooo/development/justui/apps/showcase/lib/widgets/showcase_marquee.dart) using `AnimationController` to translate two identical copies of the component strip side-by-side (`Row`) so that when the scroll offset reaches the width of one strip, it instantly resets to 0. It must scroll from right to left smoothly and without jerking at the loop point.

### R2. Showcase Components Data & Styling
Display 5 groups: Buttons, Badges, Avatars, Controls (retaining `_InteractiveControls` stateful behavior), and Input.
Style `_GroupCard` and `_Separator` dynamically based on the preset (neobrutalism vs default). Under `neobrutalism` preset, use a 2.5px border, `BorderRadius.zero`, and a solid 4x4 shadow.

### R3. Fixed Height Reporting
Update [height_reporter.dart](file:///home/yourblooo/development/justui/apps/showcase/lib/height_reporter.dart) and [main.dart](file:///home/yourblooo/development/justui/apps/showcase/lib/main.dart) to display at a fixed height of 180px.

### R4. Next.js Iframe Integration & Homepage Layout Update
Simplify [showcase-frame.tsx](file:///home/yourblooo/development/justui/apps/docs/src/components/showcase-frame.tsx) to use a fixed height of 180px and remove the postMessage height listener.
Modify [page.tsx](file:///home/yourblooo/development/justui/apps/docs/src/app/%5Blang%5D/page.tsx) to center the hero section text full-width and place the showcase marquee iframe as a full-width section beneath the hero section with border-y.

## Acceptance Criteria

### Flutter Showcase Marquee
- [ ] `ShowcaseMarquee` scrolls smoothly without any visual jump or pause at the loop boundary.
- [ ] 5 component categories are displayed (Buttons, Badges, Avatars, Controls, Input).
- [ ] `_InteractiveControls` remains interactive and responds to clicks/toggles.
- [ ] Custom Neobrutalism styling is applied correctly when the theme preset is `neobrutalism`.
- [ ] The showcase project builds successfully (using the local build script).

### Next.js Integration & Layout
- [ ] `ShowcaseFrame` has a fixed height of 180px and does not trigger dynamic resizing.
- [ ] Next.js homepage is updated to show the centered hero and full-width marquee below it.
- [ ] Dark/Light mode switching correctly triggers theme updates in the Flutter showcase iframe via postMessage.
