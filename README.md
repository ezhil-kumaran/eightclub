 Feature Overview
---
## VIDEO DEMO


https://github.com/user-attachments/assets/03cfa7cb-b7c0-462e-b009-160267625a9b

## Screen 1: Experience Type Selection
### Core Features

#### API Integration
- Fetches experiences from the staging endpoint
- Error handling with retry logic.
- Loading indicators displayed during network calls.


#### Selection Mechanism
- Multi-select support.
- Selected cards show accent borders.
- Unselected cards automatically use grayscale (ColorFilter matrix).
- Smooth animations for transitions.
- Selected IDs stored in state and logged.

#### Description Input
- Multi-line text field (250-character limit).
- Live character counter.
- Placeholder: `/ Describe your perfect hotspot`
- Fully state-managed and preserved across navigation.

#### Navigation
- Selected experience IDs and description persist when moving to the next screen.

---

## Screen 2: Onboarding Question Screen

### Core Features

#### Text Input
- Multi-line text field with 600-character limit.
- Live counter.
- Placeholder: `/ Start typing here`

#### Audio Recording
- Start, stop, and cancel controls.
- Animated waveform visualization (30 dynamic bars).
- Playback support.
- Delete option.
- MM:SS duration display.
- Visual indicators for recording states.

#### Video Recording
- Camera preview.
- Start/stop controls.
- Red recording indicator.
- In-app video playback preview.
- Delete option for recorded video.

#### Dynamic Layout Behavior
- Audio/video record buttons disappear once media is recorded.
- Next button expands using AnimatedContainer.
- Smooth transitions for layout changes.

## Animations & Transitions

### Card Animations
- Tap scale effect (1.0 → 0.95).
- Smooth grayscale transition.
- Border color animation.
- Shadow animation.
- Auto-reordering of selected cards.

### Button Animations
- Dynamic width adjustments using AnimatedContainer.
- Smooth transition effects.

### Recording Animations
- Waveform bars update every 100ms.
- Pulsing recording indicator for video.
- Fade and slide transitions for recording controls.

