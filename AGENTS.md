# AGENTS.md — Antigravity Better

Agent guide for working on this repo. Read this before touching any file.

---

## Project in One Sentence

A **single-file** (`app_root/workbench.html`) zero-dependency toolkit that injects custom CSS/JS into the Antigravity (Google's VS Code fork) AI chat panel by replacing the IDE's `workbench.html`.

---

## Build / Lint / Test Commands

**There are none.** This project has:
- No package manager (no `package.json`)
- No build system (no Webpack, Vite, etc.)
- No linter config
- No test suite

**The only "test" is manual:**
1. Edit `app_root/workbench.html`
2. Copy to the IDE install path and restart Antigravity:
   - **macOS**: `/Applications/Antigravity.app/Contents/Resources/app/out/vs/code/electron-browser/workbench/workbench.html`
   - **Windows**: `[InstallDir]/Antigravity/resources/app/out/vs/code/electron-browser/workbench/workbench.html`

**Syntax check (optional, no config needed):**
```bash
# Quick parse check — catches gross JS syntax errors
node --input-type=module < app_root/workbench.html  # won't fully work, but flags obvious issues
```

---

## File Map

| File | Purpose |
|------|---------|
| `app_root/workbench.html` | **Primary target.** All custom code lives here (v0.2.x, IDE ≥ 1.18.3) |
| `app_root/cascade-panel.html` | Legacy target (v0.1.x, IDE < 1.18.3) — lower priority |
| `.agent/workflows/anti-better-worker.md` | Agent workflow for workbench.html development |
| `.agent/workflows/html-worker.md` | Agent workflow for generic HTML page work |
| `.agent/rules/project-based-rule.md` | Always-on project rules |
| `documents/html/` | Dev logs for v0.1 and v0.2 (reference only) |

---

## Architecture: `workbench.html` Internal Structure

Everything is **inline** in this order:

1. **CSP `<meta>`** — Trusted Types enforced (`require-trusted-types-for 'script'`). The `antigravityBetter` policy is registered.
2. **`<style>` block** — All custom CSS (~315 lines). Feature CSS gated by `body.feature-xxx` class toggles.
3. **`<script src="workbench.js" type="module">`** — Original IDE bootstrap. **Never modify this.**
4. **Inline `<script>` IIFE** — All Antigravity Better JS (~850 lines), strict mode, immediately invoked.

### JS IIFE Module Order (must maintain)
1. Trusted Types policy → `safeSetHTML(el, html)`
2. I18N dictionary → `T` object, `t(key)` lookup, EN/ZH
3. Config constants → `COLOR_CONFIGS`, `FONTSIZE_CONFIGS`, `FONTFAMILY_CONFIGS`, `COPY_CONFIGS`, `HOTKEY_OPTIONS`, `AUTO_ACCEPT_CONFIGS`, `DEFAULT_BANNED_COMMANDS`
4. Settings persistence → `defaultSettings`, `loadSettings()`, `saveSettings()` via `localStorage['antigravity-better-settings']`
5. Apply functions → `applyColorSettings()`, `applyFontsizeSettings()`, `applyFontfamilySettings()`
6. `createSettingsUI(panelEl)` — imperative DOM construction, no frameworks
7. Feature modules: copy, hotkey, auto-accept, LaTeX, version-check
8. Lifecycle → `waitForAgentPanel()` polls for `.antigravity-agent-side-panel`, then `onPanelReady()`

---

## Non-Negotiable Rules

### 1. Single-file principle
All custom JS, CSS, and HTML **must stay inline** in `workbench.html`. No external files, no imports.

### 2. Zero dependencies
Pure HTML5/CSS3/ES6+. No npm, no bundler, no frameworks. Only exception: KaTeX loaded lazily via `fetch` + Blob URL (CSP workaround) when LaTeX feature is enabled.

### 3. Scope isolation
All styles **must** be scoped under `.antigravity-agent-side-panel` to avoid polluting the VS Code UI. Use:
```css
body.feature-xxx .antigravity-agent-side-panel .target-selector { ... }
```

### 4. Trusted Types — no raw innerHTML
**Never** use `innerHTML` or `outerHTML` directly. Use:
- `safeSetHTML(el, html)` — uses the registered `antigravityBetter` TT policy
- `document.createElement()` + `appendChild()` — always safe

### 5. Zero-cost when disabled
Disabled features must have **zero active JS**:
- No `MutationObserver`s running
- No active `addEventListener`s
- No `setInterval` / `setTimeout` loops
- Only create observers when feature is enabled; `disconnect()` on disable

### 6. CSS activation pattern
Feature enabled → JS adds `body.feature-xxx` class → CSS selector activates.
Feature disabled → class removed → zero CSS matching, zero overhead.

---

## Code Style

### JavaScript
- **ES6+**: arrow functions, `const`/`let`, template literals, destructuring, `async/await`
- **No `var`**: always `const` (preferred) or `let`
- **IIFE wrapper**: all code inside `(function() { 'use strict'; ... })();`
- **Semicolons**: always present
- **Line density**: CSS rules on single lines is acceptable (matches existing style). JS logic functions can be compact but readable.
- **Helper pattern**: use short `el(tag, className, text)` factory:
  ```js
  function el(tag, cls, text) {
    const e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }
  ```
- **Error handling**: wrap risky ops in `try/catch`; log with `[AB]` prefix: `console.warn('[AB] ⚠️ ...')` / `console.error('[AB] ❌ ...')`
- **Logging**: use `[AB]` prefix for all console logs, e.g. `console.log('[AB] ✅ ...')`

### CSS
- All CSS inside the single `<style>` block in `<head>`
- Selectors always include `.antigravity-agent-side-panel` as ancestor (scope isolation)
- Feature selectors: `body.feature-name .antigravity-agent-side-panel .target`
- CSS custom properties defined on `:root` for all user-configurable values
- IDs prefixed `ab-` (e.g. `#ab-settings-btn`, `#ab-overlay`, `#ab-modal`)
- Classes prefixed `ab-` for all custom UI components
- `.copy-btn`, `.copy-target`, `.latex-*` are feature-specific non-prefixed exceptions

### Naming Conventions
- **Config arrays**: `SCREAMING_SNAKE_CASE` (e.g. `COLOR_CONFIGS`, `AUTO_ACCEPT_CONFIGS`)
- **Functions**: `camelCase` verbs (e.g. `applyColorSettings`, `createSettingsUI`, `waitForAgentPanel`)
- **Settings keys**: `camelCase` matching `defaultSettings` shape (e.g. `masterEnabled`, `copyEnabled`, `sendHotkey`)
- **CSS vars**: `--kebab-case` with category prefix (e.g. `--color-user-message`, `--fontsize-ai-response`)
- **Body classes**: `kebab-case` (e.g. `color-user-message`, `fontsize-code-block`)
- **Constants**: `SCREAMING_SNAKE_CASE`
- **DOM IDs**: `ab-kebab-case`

### Comments
- **Language**: Chinese (matches existing codebase), e.g. `// ===== 颜色覆盖 =====`
- Section delimiters: `// ===== Section Name =====`
- Inline comments for non-obvious logic only

---

## Key CSS Selectors (v0.2)

| Target | Selector |
|--------|----------|
| User messages | `.bg-gray-500\/15 .whitespace-pre-wrap` |
| AI responses | `.leading-relaxed.select-text:not(.opacity-70)` |
| Thinking process | `.leading-relaxed.select-text.opacity-70` |
| Code blocks | `.leading-relaxed pre`, `.leading-relaxed pre code` |
| Send button | `button[data-tooltip-id="input-send-button-send-tooltip"]` |
| Input editor | `div[contenteditable="true"][data-lexical-editor="true"]` |
| Panel root | `.antigravity-agent-side-panel` |

---

## Adding a New Feature — Checklist

1. **Config array**: Add a `FEATURE_CONFIGS` const with `{ id, label, defaultEnabled, ... }`
2. **Default settings**: Add key to `defaultSettings` object
3. **Apply function**: `function applyFeatureSettings(panelEl) { if (!currentSettings.featureEnabled) { /* cleanup/disconnect */ return; } /* init observers/listeners */ }`
4. **CSS (if visual)**: Add `body.feature-name .antigravity-agent-side-panel ...` rules to `<style>`
5. **Settings UI**: Add an accordion section in `createSettingsUI()` in the appropriate tab
6. **Lifecycle**: Call `applyFeatureSettings(panelEl)` in `onPanelReady()`
7. **I18N**: Add keys to both `T.zh` and `T.en`
8. **Verify zero-cost**: Disable the feature and confirm no observers or listeners remain active

---

## MutationObserver Pattern (Required)

```js
let featureObserver = null;

function applyFeatureSettings(panelEl) {
  // 清理旧观察器
  if (featureObserver) { featureObserver.disconnect(); featureObserver = null; }
  if (!currentSettings.featureEnabled) return; // 零成本禁用

  // 初始化
  doFeatureWork(panelEl);

  // 监听 DOM 变化
  featureObserver = new MutationObserver(() => {
    clearTimeout(window._abFeatureTimer);
    window._abFeatureTimer = setTimeout(() => doFeatureWork(panelEl), 300);
  });
  featureObserver.observe(panelEl, { childList: true, subtree: true });
}
```

---

## Version & Release

- Version string: `APP_VERSION` constant at top of IIFE (`'0.2.1'`)
- Update version in: `APP_VERSION` const + `<style>` comment header + `README.md` badge
- Two parallel tracks: `workbench.html` (v0.2.x) and `cascade-panel.html` (v0.1.x)
