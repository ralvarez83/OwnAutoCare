import { NextResponse } from 'next/server';
import { getDriveService } from '../utils/driveService'; // Adjusted path

const APP_DATA_FILE_NAME = 'OwnAutoCare.json';

// Helper function to find the file
async function findFile(drive) {
  const res = await drive.files.list({
    spaces: 'appDataFolder',
    fields: 'files(id, name)',
    q: `name='${APP_DATA_FILE_NAME}'`,
  });
  return res.data.files.length > 0 ? res.data.files[0] : null;
}

export async function GET(request) { // LOAD DATA
  try {
    const drive = await getDriveService();
    const file = await findFile(drive);

    if (!file) {
      return NextResponse.json({ message: 'File not found in appDataFolder.' }, { status: 404 });
    }

    const fileRes = await drive.files.get({
      fileId: file.id,
      alt: 'media',
    });

    // Type assertion, as fileRes.data can be string, object, ArrayBuffer, etc.
    // For JSON, it's often parsed directly by googleapis or comes as a string.
    // Let's assume it's an object or string that needs parsing.
    let fileContent = fileRes.data;
    if (typeof fileContent === 'string') {
        try {
            fileContent = JSON.parse(fileContent);
        } catch (e) {
            // Not JSON, or malformed, return as is or handle error
        }
    }

    return NextResponse.json(fileContent);
  } catch (error) {
    console.error('GET /api/drive/file-ops Error:', error.message);
    return NextResponse.json({ error: error.message || 'Failed to load data from Google Drive' }, { status: 500 });
  }
}

export async function POST(request) { // SAVE DATA
  try {
    const drive = await getDriveService();
    const data = await request.json(); // Data to save

    const fileMetadata = {
      name: APP_DATA_FILE_NAME,
      parents: ['appDataFolder'],
    };
    const media = {
      mimeType: 'application/json',
      body: JSON.stringify(data),
    };

    const existingFile = await findFile(drive);

    let file;
    if (existingFile) {
      // Update existing file
      file = await drive.files.update({
        fileId: existingFile.id,
        media: media,
        fields: 'id,name',
      });
    } else {
      // Create new file
      file = await drive.files.create({
        resource: fileMetadata,
        media: media,
        fields: 'id,name',
      });
    }
    return NextResponse.json({ message: 'Data saved successfully to Google Drive.', fileId: file.data.id, fileName: file.data.name });
  } catch (error) {
    console.error('POST /api/drive/file-ops Error:', error.message);
    return NextResponse.json({ error: error.message || 'Failed to save data to Google Drive' }, { status: 500 });
  }
}
