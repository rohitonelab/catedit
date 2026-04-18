---
name: clipwise-automation
description: Automate video processing using the ClipWise FFmpeg server API.
---

# ClipWise Automation Skill

This skill documents how to interact with the local ClipWise FFmpeg server (port 3333) to automate video editing workflows.

## Endpoints

### 1. Upload Main Video
`POST /session/upload`
- **Description**: Creates a new session and uploads the primary video.
- **Body**: Multipart form data with a `video` field.
- **Response**: `{ sessionId: "...", assets: [...] }`

### 2. Remove Dead Air
`POST /session/:id/remove-dead-air`
- **Description**: Detects and removes silence from the main video.
- **Body**: Empty.
- **Response**: `{ success: true, asset: { ... } }`

### 3. Transcribe & Extract (Captions)
`POST /session/:id/transcribe`
- **Description**: Generates word-level timestamps using Whisper.
- **Body**: `{ assetId: "..." }` (optional, defaults to main video).
- **Response**: `{ transcription: { words: [...] } }`

### 4. Generate B-Roll
`POST /session/:id/generate-broll`
- **Description**: Uses the transcript to fetch relevant GIFs/images.
- **Body**: Empty (uses existing transcription).
- **Response**: `{ success: true, assets: [...] }`

## Usage Patterns

### Autonomous Pipeline
To run the full pipeline, execute the steps in order, passing the `sessionId` from the first response to subsequent calls.

```bash
# Example sequence
curl -F "video=@my-video.mp4" http://localhost:3333/session/upload
curl -X POST http://localhost:3333/session/$ID/remove-dead-air
curl -X POST -H "Content-Type: application/json" -d '{"assetId": "$AID"}' http://localhost:3333/session/$ID/transcribe
curl -X POST http://localhost:3333/session/$ID/generate-broll
```

## Customization Questions
Based on the workflow steps, provide answers to the following parameters:

- Step: "Remove Dead Air"
  - q_id: remove_dead_air
    ask: "Should dead air (silence) be automatically removed from the video?"
  - q_id: dead_air_threshold
    ask: "What are the configuration values for silence threshold (dB) and minimum duration?"

- Step: "Generate B-Roll"
  - q_id: broll_wanted
    ask: "Should we generate B-roll imagery for this video?"
  - q_id: broll_assets
    ask: "If B-Roll is generated, which specific visual assets (from the transcript keywords) should be fetched?"
