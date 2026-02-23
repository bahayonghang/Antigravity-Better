# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Antigravity Better** (v0.2.1) — a zero-dependency, single-HTML-file toolkit that customizes the AI chat panel in Antigravity (Google's AI-powered VS Code fork). Users replace the IDE's `workbench.html` with our modified version.

## Architecture

Everything lives in **one file**: `app_root/workbench.html` (~70KB). No build system, no package manager, no bundler.

The file structure within `workbench.html`:
1. **CSP meta tag** — Content Security Policy (Trusted Types enforced)
2. **`<style>` block** — All custom CSS (~230 lines), controlled by `body.feature-xxx` class toggles
3. **`<script src="workbench.js">` module** — Original IDE bootstrap (untouched)
4. **Inline `<script>` IIFE** — All Antigravity Better JS (~850 lines)

### JS IIFE Internal Modules (in order)
- Trusted Types policy (`antigravityBetter` for `safeSetHTML()`)
- I18N dictionary (`T` object, `t(key)` lookup, EN/ZH)
- Config constants (`COLOR_CONFIGS`, `FONTSIZE_CONFIGS`, `FONTFAMILY_CONFIGS`, `COPY_CONFIGS`, `HOTKEY_OPTIONS`, `AUTO_ACCEPT_CONFIGS`, `DEFAULT_BANNED_COMMANDS`)
- Settings persistence (`defaultSettings`, `loadSettings`, `saveSettings` via `localStorage` key `antigravity-better-settings`)
- Apply functions (`applyColorSettings`, `applyFontsizeSettings`, `applyFontfamilySettings`) — toggle body classes + CSS custom properties
- `createSettingsUI(panelEl)` — imperative DOM construction of the settings modal
- Copy feature — `MutationObserver`-based copy button injection
- Hotkey feature — `keydown` capture on Lexical editor
- Auto Accept — `MutationObserver` watches for buttons; checks `<pre>`/`<code>` against banned command list
- LaTeX rendering — lazy-loads KaTeX via `fetch` + Blob URL (CSP workaround); scans `$...$`, `$$...$$`, and `latex` code blocks
- Version check — fetches from `hub.lib00.com` API; semver comparison
- Lifecycle — `waitForAgentPanel()` polls for `.antigravity-agent-side-panel`, then calls `onPanelReady()`

### Two Versions
| File | Target |
|------|--------|
| `app_root/workbench.html` | Antigravity >= 1.18.3 (current, v0.2.x) |
| `app_root/cascade-panel.html` | Antigravity < 1.18.3 (legacy, v0.1.x) |

## Critical Development Rules

1. **Single-file principle**: All custom JS, CSS, HTML must be inline in `workbench.html`. No external files.
2. **Zero dependencies**: Pure HTML5/CSS3/JS (ES6+). No npm, no build tools.
3. **Scope isolation**: All styles/logic must be scoped under `.antigravity-agent-side-panel` to avoid polluting VS Code UI.
4. **Trusted Types**: Never use raw `innerHTML`/`outerHTML`. Use the registered `antigravityBetter` policy via `safeSetHTML()`, or build DOM with `createElement`/`appendChild`.
5. **CSS activation pattern**: Features use `body.feature-xxx .antigravity-agent-side-panel ...` selectors. Disabled features = zero CSS matching.
6. **Zero-cost when disabled**: Disabled features must have NO active JS (no observers, no listeners, no timers). Only create `MutationObserver`s when the feature is enabled; `disconnect()` on disable.
7. **Comments language**: Match existing code — comments are in **Chinese**.

## Key CSS Selectors (v0.2)

- User messages: `.bg-gray-500\/15 .whitespace-pre-wrap`
- AI responses: `.leading-relaxed.select-text:not(.opacity-70)`
- Thinking process: `.leading-relaxed.select-text.opacity-70`
- Code blocks: `.leading-relaxed pre`, `.leading-relaxed pre code`
- Send button: `button[data-tooltip-id="input-send-button-send-tooltip"]`
- Input editor: `div[contenteditable="true"][data-lexical-editor="true"]`
- Panel root: `.antigravity-agent-side-panel`

## Development Workflow

There are no build/lint/test commands. Development is:
1. Edit `app_root/workbench.html` directly
2. Copy the file to the IDE installation directory to test:
   - macOS: `/Applications/Antigravity.app/Contents/Resources/app/out/vs/code/electron-browser/workbench/workbench.html`
   - Windows: `[InstallDir]/Antigravity/resources/app/out/vs/code/electron-browser/workbench/workbench.html`
3. Restart Antigravity

## Reference Documents

- `documents/html/` — detailed development logs for v0.1 and v0.2
- `.agent/workflows/anti-better-worker.md` — v0.2 workbench development workflow and technical constraints
- `.agent/workflows/html-worker.md` — generic HTML page work workflow
