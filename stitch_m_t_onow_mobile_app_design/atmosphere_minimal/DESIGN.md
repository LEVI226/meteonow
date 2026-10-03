---
name: Atmosphere Minimal
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#3f4850'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#707881'
  outline-variant: '#bfc7d2'
  surface-tint: '#006398'
  primary: '#006194'
  on-primary: '#ffffff'
  primary-container: '#007bb9'
  on-primary-container: '#fdfcff'
  inverse-primary: '#93ccff'
  secondary: '#565e74'
  on-secondary: '#ffffff'
  secondary-container: '#dae2fd'
  on-secondary-container: '#5c647a'
  tertiary: '#006947'
  on-tertiary: '#ffffff'
  tertiary-container: '#00855b'
  on-tertiary-container: '#f5fff6'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cce5ff'
  primary-fixed-dim: '#93ccff'
  on-primary-fixed: '#001d31'
  on-primary-fixed-variant: '#004b73'
  secondary-fixed: '#dae2fd'
  secondary-fixed-dim: '#bec6e0'
  on-secondary-fixed: '#131b2e'
  on-secondary-fixed-variant: '#3f465c'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-hero:
    fontFamily: Inter
    fontSize: 64px
    fontWeight: '300'
    lineHeight: 68px
    letterSpacing: -0.04em
  display-hero-mobile:
    fontFamily: Inter
    fontSize: 52px
    fontWeight: '300'
    lineHeight: 56px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.01em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.01em
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.06em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1.25rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system expresses atmospheric clarity, precision, and calm reassurance. Tailored for a mobile-first weather utility, it pairs the clarity of contemporary Scandinavian minimalism with the tactile, fluid surfaces of modern Android and Material Design 3. 

The emotional tone balances instant scientific legibility with an airy, optimistic posture. Users opening the app under varying lighting conditions—from sharp midday sunlight to dim indoor mornings—encounter clean visual hierarchies, unambiguous environmental status signals, and a calm, uncluttered canvas. 

Visual mechanics combine soft luminous surface cards, light border definition, and focused semantic indicators. The aesthetic removes unnecessary skeuomorphic weather clutter (such as excessive raindrops, cloud photorealism, or harsh storm vignettes) in favor of crisp typographic hierarchy, micro-elevations, and purposeful color coding that delivers meteorological updates at a glance.

## Colors

The palette establishes high readability and immediate context via sky tones, deep night sky accents, and strict functional semantics:

- **Primary (`#0284C7` Sky Ocean / `#38BDF8` Light Breeze)**: Drives active navigation targets, primary interactive highlights, high-precipitation graphs, and key iconography.
- **Secondary (`#0F172A` Deep Midnight Navy / `#1E293B` Slate Dusk)**: Establishes strong contrast for critical numerical metrics, primary headers, sheet surfaces, and grounding components.
- **Tertiary & Status Green (`#10B981` Emerald Live)**: Communicates live telemetry, optimal air quality index (AQI), and online synchronization status.
- **Warning & Cached (`#F59E0B` Solar Amber)**: Identifies stale data states, cached sync timestamps, and moderate UV/weather alerts.
- **Destructive & Alert (`#EF4444` Soft Rose Crimson)**: Flags network disconnections, severe storm warnings, and critical sensor failures.
- **Neutrals & Surfaces**: Background surfaces anchor on `#F8FAFC`, cards layer on `#FFFFFF` with faint atmospheric sky tints (`#F0F9FF`), and structural borders rest on `#E2E8F0` to prevent harsh visual cuts.

## Typography

Typography prioritizes fast numerical comprehension and high optical clarity across variable mobile screens using `Inter`.

- **Temperature Scales**: Current temperatures are expressed using `display-hero` (`52px` on standard mobile screens and `64px` on extended layouts) with a `300` light weight and tight letter spacing. This prevents the large numerical readout from overpowering auxiliary metric cards.
- **Tabular Figures**: All quantitative metrics—including temperature figures, barometric pressure (hPa), humidity percentages, and wind speeds—must enforce OpenType tabular figures (`tnum`) in Flutter text styles to prevent horizontal shifting during live data refreshes.
- **Metric Labels & Metadata**: Labels apply uppercase tracking via `label-sm` or `label-md` with `500` and `600` weights, ensuring crisp contrast against tinted card surfaces.

## Layout & Spacing

The layout utilizes a structured 4-column fluid mobile grid anchored around touch-first ergonomics and vertical scan patterns:

- **Touch Safety & Metrics**: Interactive elements enforce strict minimum bounding targets of `48px x 48px` to guarantee frictionless single-handed Android operation.
- **Vertical Hierarchy**: Screens follow a top-down information cascade: Top App Bar and Location/Sync Pills -> Hero Temperature & Condition Overview -> Hourly Horizontal Rail -> Daily 7-Day Matrix -> 2-Column Metric Grid (Wind, Humidity, UV, Pressure).
- **Rhythm**: Standard structural gaps between composite weather cards are locked to `space-md` (`16px`). Compact sub-data chips rely on `space-xs` (`4px`) and `space-sm` (`8px`) inner margins to maintain high spatial density without visual noise.

## Elevation & Depth

Visual depth employs soft ambient occlusion, subtle translucent fills, and low-contrast borders instead of heavy drop shadows:

- **Surface Level 0 (Canvas)**: Solid neutral `#F8FAFC`. Provides a grounded, glare-free background.
- **Surface Level 1 (Default Metric Cards)**: Crisp white (`#FFFFFF`) with a faint atmospheric border (`1px solid #E2E8F0`) and an ambient tinted drop shadow: `0px 4px 20px -2px rgba(15, 23, 42, 0.04)`.
- **Surface Level 2 (Selected / Active Hourly Pills & Modals)**: Subtle sky blend (`background: #F0F9FF; border: 1px solid #BAE6FD`) with an ambient shadow: `0px 8px 24px -4px rgba(2, 132, 199, 0.08)`.
- **Surface Level 3 (Floating Bars & Alerts)**: Applied to sticky banners, floating search inputs, and sheets. Tinted drop shadow: `0px 12px 32px -4px rgba(15, 23, 42, 0.08)`.
- **Backdrop Filters**: Overlays and sticky headers use backdrop blur (`sigmaX: 12`, `sigmaY: 12`) coupled with `rgba(248, 250, 252, 0.85)` surface transmission.

## Shapes

The design system implements `roundedness: 2`, delivering balanced geometry matching Material 3 and modern Android hardware curves:

- **Cards & Data Modules**: Base corner radius of `16px` (`rounded-lg`), mirroring the gentle edge radii of contemporary handheld displays.
- **Action Buttons & Inputs**: Standard radius of `12px` to keep touch targets distinct from background cards.
- **Pills, Badges & Status Chips**: Full pill geometry (`rounded-xl` / `9999px`) to immediately distinguish ephemeral status tags and interactive filter toggles from informational cards.

## Components

### Status Badges & Sync Banners
- **Live Data Pill**: Pill-shaped chip with `#ECFDF5` background, `#10B981` border, `#065F46` label (`label-sm`), paired with a pulsing 6px `#10B981` dot.
- **Cached Data Pill**: Pill-shaped chip with `#FFFBEB` background, `#F59E0B` border, and `#92400E` label. Accompanied by a static clock icon and last-updated relative timestamp.
- **Offline / Sync Banner**: Full-width top dock banner with `#FEF2F2` background, `#EF4444` left accent border (3px), `#991B1B` body text, and an integrated `#DC2626` retry action. Minimum height `48px`.

### Weather Metric Cards
- Standard cards feature a dual layout: primary label and icon anchored at top-left/top-right (`12px` padding), with bold values (`headline-md`) positioned at bottom-left. Sub-labels (e.g., "Feels like 18°") utilize `body-sm` in `#64748B`.
- Faint atmospheric linear gradient allowed on hero cards: `180deg from #FFFFFF to #F0F9FF`.

### Buttons & Interactive Controls
- **Primary Button**: Solid `#0284C7` fill with white text, minimum height `48px`, `12px` radius. Active state scales to `0.98` with `#0369A1` color overlay.
- **Secondary / Ghost Button**: Translucent fill (`#F1F5F9`) with `#0F172A` text, hover/active fill `#E2E8F0`.
- **Hourly Scroller Item**: Vertical mini-card (`64px` wide x `104px` high). Unselected state shows transparent fill with muted text; selected state transitions to `#E0F2FE` background and `#0284C7` border.

### Form Inputs & Search
- Location search field features a `48px` height, `#FFFFFF` background, `#CBD5E1` border (`1px`), `#0284C7` focus border (`2px`), with an integrated clear button and search magnifying icon in `#64748B`.

### Navigation Bar
- Flutter `NavigationBar` pattern adhering to Material Design 3 guidelines: `#FFFFFF` surface with `1px` top border (`#E2E8F0`). Height of `64px` excluding safe area. Active indicator pill uses `#E0F2FE` with `#0284C7` icon coloring and `#0F172A` typography.