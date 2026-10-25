/** What the keyboard can reach inside a view's semantics tree. */
const CONTROLS = '[tabindex="0"]:not(flutter-view), input, textarea';

/**
 * Keeps the `flutter-view` of [host] out of the Tab order while the view
 * has no control of its own (badge, avatar, table and the like).
 *
 * The engine gives every view `tabindex="0"` so Tab can enter it; Dart then
 * moves focus to the first control. A view without controls would keep
 * that focus on an empty, unlabelled element, so Tab would stop on nothing.
 * A view with controls is left to the engine, which toggles the attribute
 * itself while focus is inside. Returns the cleanup.
 */
export function keepEmptyViewOutOfTabOrder(host: HTMLElement): () => void {
  let forced = false;
  const sync = () => {
    const view = host.querySelector('flutter-view');
    if (!view) return;
    if (host.querySelector(CONTROLS) === null) {
      forced = true;
      if (view.getAttribute('tabindex') !== '-1') {
        view.setAttribute('tabindex', '-1');
      }
    } else if (forced) {
      forced = false;
      view.setAttribute('tabindex', '0');
    }
  };
  const observer = new MutationObserver(sync);
  observer.observe(host, {
    subtree: true,
    childList: true,
    attributes: true,
    attributeFilter: ['tabindex'],
  });
  sync();
  return () => observer.disconnect();
}
