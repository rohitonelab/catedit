---
name: avatar-layering
description: Create a talking head video with overlaid graphics, PiP layouts, and captions.
---

# Avatar Layering Workflow

## Purpose
This skill generates a professional-looking video featuring a "talking head" (avatar) as the primary focus, with dynamic graphics overlaid (such as PiP - Picture in Picture images, lower-third texts, or full-screen B-roll moments with the avatar scaled down).

## Core logic
1. Detect face bounding box properties or safe action areas to position avatars correctly.
2. Layout text overlays and B-roll imagery such that they do not obscure the speaker's face.
3. Configure the `DynamicAnimation` template or similar layout engines to toggle between `Full Avatar`, `Avatar PiP`, and `Avatar With Lower Third`.

## Remotion Props
- `avatarScale`: Configured for normal or PiP mode.
- `layout`: "split-screen" | "pip" | "full"

## Customization Questions
Based on the workflow steps, provide answers to the following parameters:

- Step: "Set up Avatar Layout"
  - q_id: layout_type
    ask: "Do you prefer a Picture-in-Picture layout, split screen, or full screen for overlays?"
  - q_id: layout_timeline
    ask: "Define the array of timestamps for when to use Full Screen Avatar vs Picture-in-Picture layout based on topic changes."

- Step: "Add graphical lower-thirds"
  - q_id: graphics_placement
    ask: "Specify the exact timestamps and text content for any lower-third animations that need to appear mapped to key phrases."

- Step: "Add B-roll graphics"
  - q_id: broll_mapping
    ask: "If B-roll assets are provided, identify exactly which timestamps they cover over the avatar."
