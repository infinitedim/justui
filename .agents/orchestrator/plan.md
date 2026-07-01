# Plan: JustUI Showcase Marquee & Homepage Layout Update

We are updating the Flutter Showcase Web app to a smooth, infinite horizontal marquee and integrating it into the Next.js homepage layout as a full-width section under the centered hero.

## Milestones

1. **M1: Flutter Showcase Marquee & Style**
   - Goal: Rebuild `apps/showcase/lib/widgets/showcase_marquee.dart` with infinite scrolling using `AnimationController` and apply default/neobrutalism dynamic styles to 5 component groups.
   - Status: Completed
2. **M2: Fixed Height & Height Reporter**
   - Goal: Update `apps/showcase/lib/height_reporter.dart` and `apps/showcase/lib/main.dart` to use fixed height of 180px.
   - Status: Completed (facade resolved, dynamic height reporting restored)
3. **M3: Next.js docs showcase & homepage**
   - Goal: Update Next.js component `showcase-frame.tsx` and homepage `page.tsx` layout and styling.
   - Status: Completed
4. **M4: Build, Run, & Audit**
   - Goal: Verify build succeeds for both showcase and docs, check styling and alignment, and run forensic audit.
   - Status: Completed (Challenger, Reviewer, and Auditor verified and approved)

## Verification Criteria
- `ShowcaseMarquee` scrolls smoothly without any visual jump or pause at the loop boundary. (Passed)
- 5 component categories are displayed (Buttons, Badges, Avatars, Controls, Input). (Passed)
- `_InteractiveControls` remains interactive and responds to clicks/toggles. (Passed)
- Custom Neobrutalism styling is applied correctly when the theme preset is `neobrutalism`. (Passed)
- The showcase project builds successfully (using the local build script). (Passed)
- `ShowcaseFrame` has a fixed height of 180px and does not trigger dynamic resizing. (Passed)
- Next.js homepage is updated to show the centered hero and full-width marquee below it. (Passed)
- Dark/Light mode switching correctly triggers theme updates in the Flutter showcase iframe via postMessage. (Passed)
