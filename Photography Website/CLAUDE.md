# Photography Portfolio Website — Project Brief

---

## Project State *(read this first — gives 90% of session context)*

### File Structure (complete, as of 2026-06-17)

```
photography-portfolio/
├── index.html                        # Home page: category list left + silent cycling image right
├── gallery.html                      # Gallery page: grid + lightbox, filtered by ?category=
├── vercel.json                       # Deployment config — no framework, output dir = "."
├── sync-gallery.sh                   # PRIMARY workflow script (see Scripts below)
├── push-photos.sh                    # Legacy simpler push script (no diff check — prefer sync-gallery.sh)
├── CLAUDE.md                         # This file
├── styles/
│   ├── base.css                      # ← DO NOT RE-READ UNLESS ASKED (see below)
│   ├── layout.css                    # ← DO NOT RE-READ UNLESS ASKED (see below)
│   └── gallery.css                   # Gallery grid + lightbox styles
├── scripts/
│   ├── gallery.js                    # Grid render + lightbox logic (open/close, nav, swipe, keyboard)
│   ├── home.js                       # Silent crossfade cycling through all photos on home page
│   ├── categories.js                 # AUTO-GENERATED — do not edit by hand
│   ├── generate-categories.js        # Node.js generator: node scripts/generate-categories.js
│   └── generate-categories.ps1       # PowerShell generator: called by push-photos.sh
└── images/
    ├── architecture/                 # 15 photos
    ├── flight/                       # 15 photos
    ├── landscapes/                   # 9 photos
    ├── portraits/                    # 9 photos
    └── rockets/                      # 17 photos
```

### Scripts — what each one does

| Script | One-sentence summary |
|---|---|
| `sync-gallery.sh` | **Primary workflow** — diffs `images/` against `categories.js`, regenerates it if changed, then commits and pushes; exits with no-op if nothing changed. |
| `push-photos.sh` | Older, simpler push script — regenerates `categories.js` unconditionally, stages image files, commits, and pushes; does not diff first. |
| `scripts/generate-categories.js` | Node.js generator that scans `images/` subfolders and writes a fresh `scripts/categories.js`; run with `node scripts/generate-categories.js`. |
| `scripts/generate-categories.ps1` | PowerShell equivalent of the above; called internally by `push-photos.sh` via `powershell.exe`. |

> **Prefer `sync-gallery.sh`** for all photo management — it's the complete, idempotent workflow.

### Current Categories

| Category | Folder | Photo count |
|---|---|---|
| Landscapes | `images/landscapes/` | 9 |
| Portraits | `images/portraits/` | 9 |
| Architecture | `images/architecture/` | 15 |
| Flight | `images/flight/` | 15 |
| Rockets | `images/rockets/` | 17 |

`categories.js` is auto-generated from these folders — never edit it by hand. Cover image defaults to the first file alphabetically, or any file named `cover.*`.

### Deployment

- **Host:** Vercel (auto-deploys on every push to GitHub `main`)
- **Build step:** None — `vercel.json` sets no framework preset and serves the project root directly
- **Workflow:** Edit files locally → `bash sync-gallery.sh` (or `git commit && git push`) → Vercel deploys automatically

### Do Not Re-Read Unless Asked

These files are stable and rarely change. Skip them at session start; only read them if directly debugging their content:

- `styles/base.css` — CSS reset, custom property tokens, typography rules; settled design system
- `styles/layout.css` — nav, footer, home-page two-column layout; structurally stable
- `index.html` — home page HTML structure; changes only when adding new layout sections
- `vercel.json` — one-line deployment config; almost never changes

---

## Project Overview

A personal photography portfolio website that displays photos in a categorized gallery format. The site should feel like a curated exhibition space: dark, minimal, and image-first. Every design decision defers to the photographs themselves.

---

## Goals

- Showcase photography organized by category (e.g. Landscapes, Portraits, Street, Architecture, etc.)
- Allow visitors to browse categories and view individual photos in a lightbox
- Feel premium, editorial, and distraction-free
- Be fully responsive (mobile, tablet, desktop)

---

## Tech Stack

- **Framework:** Plain HTML + CSS + Vanilla JS (no build step required) OR React if preferred
- **Styling:** CSS custom properties; no CSS frameworks unless explicitly requested
- **Images:** Static files in `/images/<category>/` folders
- **No backend required** — purely static site
- **Deployment:** Vercel, plain static site. A `vercel.json` at the project root sets no framework preset and output directory to `.` (the project root). No build step.

---

## File Structure to Create

```
photography-portfolio/
├── index.html           # Landing page with category grid
├── gallery.html         # Category gallery page (filtered by ?category=)
├── sync-gallery.sh      # Single workflow script — scan → diff → commit → push
├── styles/
│   ├── base.css         # Reset, tokens, typography
│   ├── layout.css       # Grid, nav, footer
│   └── gallery.css      # Gallery grid + lightbox
├── scripts/
│   ├── gallery.js             # Masonry/grid render + lightbox logic
│   ├── categories.js          # Category data and image manifest (auto-generated)
│   ├── generate-categories.ps1  # PowerShell generator called by sync-gallery.sh
│   └── home.js                # Silent crossfade on home page
├── images/
│   ├── landscapes/
│   ├── portraits/
│   ├── street/
│   └── architecture/
└── CLAUDE.md            # This file
```

---

## Design Direction

**Aesthetic:** True minimalist high-end art gallery. Think MoMA or Gagosian — pure black surrounds every image so nothing competes with the work. No cards, no borders, no drop shadows, no decorative elements of any kind. The UI is nearly invisible; only the photographs exist.

**Core principle:** Maximum negative space. Images float on black. Typography is sparse and whisper-quiet. If an element doesn't serve the photograph, it doesn't exist.

**Color Palette:**
- Background: `#000000` (pure black — not near-black, not dark gray. Black.)
- Nav/UI surface: `#000000` (same black — no contrast between nav and page)
- Dividers: none (use spacing, not lines)
- Text primary: `#ffffff` (pure white)
- Text secondary: `#555555` (dark gray — for counts, dates, captions)
- Active/hover accent: `#ffffff` (opacity shift only, no color change)
- Zero use of color anywhere in UI chrome

**Typography:**
- Display: `"Helvetica Neue"`, `Arial`, sans-serif — no web font download. Pure system sans. Ultra-light weight (`font-weight: 200`) for headings and the site name. This is deliberate: gallery signage is always quiet.
- Labels/nav: same family, `font-weight: 300`, widely letter-spaced (`letter-spacing: 0.15em`), all uppercase, very small (`11–12px`)
- Captions in lightbox: `font-weight: 300`, italic, left-aligned, small
- No decorative type. No serifs. No display fonts.

**Spacing philosophy:** Generous to extreme. The home page category grid has wide gutters. Gallery grid has tight-but-breathable gaps (`4px`–`8px`) so images sit close without touching — like prints on a wall. Lightbox padding is generous so the photo never feels cramped.

**Signature element:** The gallery grid uses no hover overlays, no title reveals, no effects. Images are simply images. When a photo is clicked, the lightbox transition is a clean crossfade — no sliding, no scaling. The restraint IS the signature. The one moment of life: the nav site name fades to `0.4` opacity on scroll, then returns on hover — almost invisible, then present.

---

## Pages & Features

### 1. Home (`index.html`)
- No hero image. Open directly to the site name (small, uppercase, ultra-light weight, top-left) and category list.
- Category list: a clean vertical stack on the left (desktop) or stacked full-width (mobile) — just the category name and photo count in muted gray. Nothing else.
- To the right of the list (desktop): a silent, slow crossfade cycling through all photos across all categories every 4 seconds. No controls, no indicators. Just images quietly changing.
- The full photo pool (every photo from every category) is shuffled randomly at page load. Each photo is shown exactly once before the pool reshuffles — no photo repeats until all have been displayed.
- All preview images use `object-fit: contain` with a transparent (black) background so portrait/vertical images are never cropped.
- No footer. The page ends when the content ends.

### 2. Gallery (`gallery.html?category=landscapes`)
- Pure black page. No header graphic, no hero.
- Nav: site name top-left (ultra-light), category links top-right (uppercase, small, tracked) — both white at `0.5` opacity, full on hover.
- Active category: `opacity: 1`; all others at `0.4`.
- Photo grid: 3 equal columns desktop, 2 tablet, 1 mobile. Tight `6px` gaps. No card backgrounds, no borders. Consistent row heights (contact-sheet feel). `object-fit: contain` with transparent (black) background so portrait/vertical images are never cropped.
- No hover effects on photos — completely still until clicked.

### 3. Lightbox (overlay, no separate page)
- Pure `#000000` full-screen overlay.
- Photo centered, max `90vw × 85vh`, no border, no shadow.
- Caption below photo (left-aligned): title in white `font-weight: 300`, date in muted gray.
- Prev/next: thin `←` `→` text arrows at far edges, low opacity until hovered.
- Close: `×` top-right, same low-opacity treatment.
- Transition: crossfade only (`opacity` ~300ms). No movement, no scaling.
- Keyboard: `←` `→` navigate, `Esc` close. Mobile: swipe to navigate, tap outside to close.

---

## Image Data Format

Define images in `scripts/categories.js` as a JS object so Claude Code can populate it easily:

```js
const CATEGORIES = [
  {
    id: "landscapes",
    label: "Landscapes",
    cover: "images/landscapes/cover.jpg",
    photos: [
      { src: "images/landscapes/01.jpg", title: "Golden Hour, Utah", date: "2024" },
      { src: "images/landscapes/02.jpg", title: "Misty Peaks", date: "2023" },
      // ... add more
    ]
  },
  {
    id: "portraits",
    label: "Portraits",
    cover: "images/portraits/cover.jpg",
    photos: [
      { src: "images/portraits/01.jpg", title: "Market Day", date: "2024" },
    ]
  },
  // Add categories as needed
];
```

---

## Photo Management Workflow

**`sync-gallery.sh` is the single script for all photo and category updates.** Run it from Git Bash at the project root after making any changes to the `images/` folder — adding photos, deleting photos, adding a new category folder, renaming or removing a category folder.

```bash
bash sync-gallery.sh
```

### What it does on each run

1. **Parses** `scripts/categories.js` to read the currently registered categories and photos.
2. **Scans** the `images/` folder to see what actually exists on disk.
3. **Diffs** the two:
   - New category folders not yet in `categories.js` → detected as added
   - Category folders that have been renamed or deleted → detected as removed
   - New image files inside any category folder → detected as added
   - Image files that have been renamed or deleted → detected as removed
4. **If nothing changed:** exits immediately with `No changes detected — nothing to update.`
5. **If changes were found:**
   - Regenerates `scripts/categories.js` to exactly reflect the current `images/` folder
   - Stages `images/` and `scripts/categories.js`
   - Commits with an auto-generated message describing what changed and the date, e.g.:
     `Sync gallery: added 1 category (wildlife); added 3 photos -- 2026-06-17`
   - Pushes to GitHub (Vercel auto-deploys on push)

### Typical workflows

**Add photos to an existing category:**
Drop the files into the appropriate `images/<category>/` folder, then run `bash sync-gallery.sh`.

**Add a new category:**
Create a new subfolder under `images/` (e.g. `images/street/`), add photos to it, then run `bash sync-gallery.sh`. The folder name becomes the category `id`; the label is auto-capitalized from the folder name.

**Rename a category:**
Rename the folder in `images/` (e.g. `images/flight/` → `images/aviation/`), then run `bash sync-gallery.sh`. The old category is removed and the new one is added automatically.

**Remove a category:**
Delete the folder from `images/`, then run `bash sync-gallery.sh`.

> **Note:** `scripts/categories.js` is fully auto-generated on every sync — do not edit it by hand. The cover image for each category defaults to the first file alphabetically in that folder. To pin a specific cover, name the file `cover.jpg` (or any image extension starting with `cover.`).

---

## Instructions for Claude Code

1. **Scaffold the full file structure** listed above
2. **Build `index.html`** — category list left + silent cycling image right. No hero, no footer, no decoration.
3. **Build `gallery.html`** — contact-sheet grid + crossfade lightbox
4. **Write all CSS** from the tokens above. Use CSS custom properties. Enforce: `background: #000`, no borders, no shadows, no border-radius on images, no hover overlays on grid photos.
5. **Write `gallery.js`** — grid render from data, lightbox open/close, crossfade transition, prev/next, keyboard nav, touch swipe
6. **Write `home.js`** — silent image crossfade cycling through category covers
7. **Populate `categories.js`** with 4 categories (Landscapes, Portraits, Street, Architecture), 4 photos each, using `https://picsum.photos` placeholder URLs
8. **Enforce restraint:** if any CSS rule adds decoration not listed in the design direction, remove it. No gradients, no glows, no colored accents, no rounded corners.
9. **Responsive:** 375px / 768px / 1280px breakpoints
10. **No external dependencies** — no Google Fonts, no icon libraries, no JS frameworks

---

## Customization Notes (fill in before handing off)

- [ ] **Your name / studio name:** ___________________
- [ ] **Categories you want:** ___________________
- [ ] **Number of photos per category (approx):** ___________________
- [ ] **Do you want a contact/about page?** Yes / No
- [ ] **Any specific font preferences?** ___________________
- [ ] **Domain / deployment target:** Netlify / GitHub Pages / Other

---

## Future Enhancements (optional, flag for later)

- EXIF data display in lightbox (camera, lens, settings)
- Filter by tag within a category
- Password-protected private galleries
- CMS integration (Contentful, Sanity) to manage photos without editing code
- Lazy loading + blur-up image placeholders for performance
