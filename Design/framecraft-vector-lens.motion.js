/**
 * Enables one-shot disclosure motion after user interaction, never on initial render.
 * @private
 * @returns {void} Leaves native disclosure and keyboard behavior unchanged.
 */
(() => {
  const root = document.getElementById(FRAMECRAFT_VECTOR_MOTION.rootId);
  if (!root) return;

  /**
   * Marks the activated disclosure before its native open state changes.
   * @private
   * @param {MouseEvent} event - A pointer or keyboard-generated activation event.
   * @returns {void} Enables CSS motion without changing content or preventing the action.
   */
  function markDisclosureMotion(event) {
    if (!(event.target instanceof Element)) return;
    const summary = event.target.closest(FRAMECRAFT_VECTOR_MOTION.summarySelector);
    const disclosure = summary?.parentElement;
    if (disclosure instanceof HTMLDetailsElement && root.contains(disclosure)) {
      disclosure.classList.add(FRAMECRAFT_VECTOR_MOTION.motionClass);
    }
  }

  root.addEventListener(FRAMECRAFT_VECTOR_MOTION.activationEvent, markDisclosureMotion);
})();
