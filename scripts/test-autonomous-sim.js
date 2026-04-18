import fs from 'fs';
import path from 'path';

async function testAutonomous() {
  const videoPath = 'D:\\catedit\\test-video.mp4';
  const url = 'http://localhost:3333/autonomous/process';

  console.log('--- STARTING AUTONOMOUS TEST ---');
  console.log('Video:', videoPath);

  // Using fetch with FormData
  const formData = new FormData();
  const fileBuffer = fs.readFileSync(videoPath);
  const blob = new Blob([fileBuffer], { type: 'video/mp4' });
  
  formData.append('video', blob, 'test-video.mp4');
  formData.append('prompt', 'A viral real estate style edit with kinetic text overlays on key phrases and a fast-paced intro.');

  try {
    console.log('Sending request to /autonomous/process...');
    const response = await fetch(url, {
      method: 'POST',
      body: formData
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('Error status:', response.status);
      console.error('Error details:', errorText);
      return;
    }

    const data = await response.json();
    console.log('SUCCESS!');
    console.log('Session ID:', data.sessionId);
    console.log('Assets registered:', data.totalAssets);
    
    console.log('\n--- WAITING FOR BACKGROUND PROCESSING (30s) ---');
    await new Promise(r => setTimeout(r, 45000));
    console.log('Polling session history for results...');
    
    // Check if skill extraction works
    console.log('\n--- TESTING SKILL EXTRACTION ---');
    const exportResponse = await fetch(`http://localhost:3333/session/${data.sessionId}/export-skill`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'viral-real-estate-workflow',
        description: 'Auto-extracted from a high-energy real estate edit simulation.'
      })
    });

    const exportData = await exportResponse.json();
    console.log('Skill Export Result:', exportData);

  } catch (error) {
    console.error('Test failed:', error.message);
  }
}

testAutonomous();
