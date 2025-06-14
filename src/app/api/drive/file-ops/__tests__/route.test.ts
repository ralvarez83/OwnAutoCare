import './jest.polyfills'; // <--- IMPORT POLYFILLS FIRST

// Attempt to mock next-auth very early to prevent 'jose' from being imported via driveService
jest.mock('next-auth/next', () => ({
  getServerSession: jest.fn().mockResolvedValue({
    accessToken: 'mock-access-token',
    // Add other session properties if needed by driveService logic (though driveService itself is mocked)
  }),
}));
// Mock authOptions as well if driveService imports it directly
jest.mock('@/app/api/auth/[...nextauth]/route', () => ({ // Adjust path to your authOptions
  authOptions: {}, // Provide a minimal mock for authOptions
}));

import { GET, POST } from '../route'; // Adjust path as needed
import { getDriveService } from '../../utils/driveService'; // Adjust path as needed
import { NextRequest, NextResponse } from 'next/server';
import { Readable } from 'stream';

// Polyfill/Mock Web API objects for Node.js environment (Jest)
if (typeof global.Request === 'undefined') {
  global.Request = require('node-fetch').Request as any;
  global.Response = require('node-fetch').Response as any;
  global.Headers = require('node-fetch').Headers as any;
  global.URL = require('url').URL as any;
}

// Mock driveService and its specific exports
// findFile will be a jest.fn() created by the mock factory
jest.mock('../../utils/driveService', () => ({
  getDriveService: jest.fn(),
  findFile: jest.fn(), // This will be the mock for findFile
}));

// Import the mocked versions
import { getDriveService, findFile as mockFindFileFromDriveServiceModule } from '../../utils/driveService';

const mockGetDriveService = getDriveService as jest.Mock;
const mockFindFile = mockFindFileFromDriveServiceModule as jest.Mock;


// Helper to create NextRequest objects
function createMockRequest(method: string, body?: any, headers?: Record<string, string>): NextRequest {
  const url = 'http://localhost/api/drive/file-ops';
  const headerInit = new Headers({ 'Content-Type': 'application/json', ...headers });

  const request = new Request(url, {
    method,
    headers: headerInit,
    body: body ? JSON.stringify(body) : null,
  });
  // Cast to NextRequest. In a real Next.js environment, this would be handled.
  // For testing, ensuring the interface matches is often sufficient.
  return new NextRequest(request, {
    // NextRequest specific internals if any, for now, an empty object or relevant mocks
  });
}

// Mock NextResponse for convenience if specific NextResponse methods are used by the route
jest.mock('next/server', () => ({
  ...jest.requireActual('next/server'),
  NextResponse: {
    json: jest.fn((body, init) => new Response(JSON.stringify(body), init)),
    // Mock other NextResponse methods if used by your route (e.g., text, redirect)
  },
}));

describe('/api/drive/file-ops', () => {
  let mockDriveFiles: any;

  beforeEach(() => {
    jest.clearAllMocks();
    mockDriveFiles = {
      get: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      list: jest.fn(), // Add list here
    };
    // Default mock for getDriveService to return the drive object with mocked files methods
    mockGetDriveService.mockResolvedValue({ files: mockDriveFiles });
    // Clear the findFile mock (imported from the mocked driveService)
    mockFindFile.mockClear();
  });

  describe('GET', () => {
    it('should return file content if found', async () => {
      const mockFileContent = { vehicles: [{ id: '1', make: 'Test' }] };
      const mockFile = { id: 'test-file-id', name: 'OwnAutoCare.json' }; // findFile returns an object

      // Mock findFile to return a file object
      mockFindFile.mockResolvedValueOnce(mockFile);

      // Use the existing mock function from mockDriveFiles and set its implementation
      mockDriveFiles.get.mockImplementation((args) => {
        // console.log('mockDriveFiles.get MOCK IMPLEMENTATION CALLED with args:', JSON.stringify(args));
        if (args.fileId === mockFile.id) {
          return Promise.resolve({
            data: Readable.from(JSON.stringify(mockFileContent)),
            status: 200,
          });
        }
        return Promise.reject(new Error('mockDriveFiles.get called with unexpected fileId'));
      });

      const req = createMockRequest('GET');
      const response = await GET(req);
      const jsonResponse = await response.json();

      expect(response.status).toBe(200);
      expect(jsonResponse).toEqual(mockFileContent);
      expect(getDriveService).toHaveBeenCalled();
      expect(mockFindFile).toHaveBeenCalledWith(expect.objectContaining({ files: mockDriveFiles })); // APP_DATA_FILE_NAME is used internally by findFile
      expect(mockDriveFiles.get).toHaveBeenCalledWith(
        { fileId: mockFile.id, alt: 'media' }
        // { responseType: 'stream' } // googleapis v105+ might not need/use responseType here for streams
      );
    });

    it('should return 404 if file not found', async () => {
      mockFindFile.mockResolvedValueOnce(null); // findFile returns null

      const req = createMockRequest('GET');
      const response = await GET(req);
      const jsonResponse = await response.json();

      expect(response.status).toBe(404);
      // Adjusted to match the actual error message from the route
      expect(jsonResponse).toEqual({ message: 'File not found in appDataFolder.' });
      expect(getDriveService).toHaveBeenCalled();
      expect(mockFindFile).toHaveBeenCalledWith(expect.objectContaining({ files: mockDriveFiles }));
      expect(mockDriveFiles.get).not.toHaveBeenCalled();
    });

    it('should return 500 if Drive API fails during get', async () => {
      const mockFile = { id: 'test-file-id', name: 'OwnAutoCare.json' }; // findFile returns an object
      mockFindFile.mockResolvedValueOnce(mockFile);

      // Use the existing mock function
      mockDriveFiles.get.mockRejectedValueOnce(new Error('Drive API error'));

      const req = createMockRequest('GET');
      const response = await GET(req);
      const jsonResponse = await response.json();

      expect(response.status).toBe(500);
      // Adjusted to match the actual error message format from the route's catch block
      expect(jsonResponse).toEqual({ error: 'Drive API error' });
      expect(getDriveService).toHaveBeenCalled();
      expect(mockFindFile).toHaveBeenCalledWith(expect.objectContaining({ files: mockDriveFiles }));
      expect(mockDriveFiles.get).toHaveBeenCalledWith(
        { fileId: mockFile.id, alt: 'media' }
        // { responseType: 'stream' }
      );
    });
  });

  describe('POST', () => {
    it('should create a new file if not exists', async () => {
      const mockRequestBody = { vehicles: [{ id: 'new', make: 'NewCar' }] };
      const mockCreatedFileId = 'new-file-id';

      // Mock findFile (imported from the mocked driveService) to return null (file doesn't exist)
      mockFindFile.mockResolvedValueOnce(null);

      // Use the existing mock function
      mockDriveFiles.create.mockImplementation((args) => {
        // console.log('mockDriveFiles.create MOCK IMPLEMENTATION CALLED with args:', JSON.stringify(args));
        return Promise.resolve({
          data: { id: mockCreatedFileId, name: 'OwnAutoCare.json' },
          status: 200,
        });
      });

      const req = createMockRequest('POST', mockRequestBody);
      const response = await POST(req);
      const jsonResponse = await response.json();

      expect(response.status).toBe(200);
      expect(jsonResponse).toEqual({
        message: 'Data saved successfully to Google Drive.', // Adjusted message
        fileId: mockCreatedFileId,
        fileName: 'OwnAutoCare.json', // Added fileName
      });
      expect(getDriveService).toHaveBeenCalled();
      expect(mockFindFile).toHaveBeenCalledWith(expect.objectContaining({ files: mockDriveFiles }), 'OwnAutoCare.json');
      expect(mockDriveFiles.create).toHaveBeenCalledWith({
        requestBody: {
          name: 'OwnAutoCare.json',
          mimeType: 'application/json',
          parents: ['appDataFolder'],
        },
        media: {
          mimeType: 'application/json',
          body: JSON.stringify(mockRequestBody),
        },
        fields: 'id',
      });
      expect(mockDriveFiles.update).not.toHaveBeenCalled();
    });

    it('should update existing file', async () => {
      const mockRequestBody = { vehicles: [{ id: 'updated', make: 'UpdatedCar' }] };
      const existingFileId = 'existing-file-id';

      mockFindFile.mockResolvedValueOnce(existingFileId);

      // Use the existing mock function
      mockDriveFiles.update.mockImplementation((args) => {
        // console.log('mockDriveFiles.update MOCK IMPLEMENTATION CALLED with args:', JSON.stringify(args));
        return Promise.resolve({
          data: { id: existingFileId, name: 'OwnAutoCare.json' },
          status: 200,
        });
      });

      const req = createMockRequest('POST', mockRequestBody);
      const response = await POST(req);
      const jsonResponse = await response.json();

      expect(response.status).toBe(200);
      expect(jsonResponse).toEqual({
        message: 'Data saved successfully to Google Drive.', // Adjusted message
        fileId: existingFileId,
        fileName: 'OwnAutoCare.json', // Added fileName
      });
      expect(getDriveService).toHaveBeenCalled();
      expect(mockFindFile).toHaveBeenCalledWith(expect.objectContaining({ files: mockDriveFiles }), 'OwnAutoCare.json');
      expect(mockDriveFiles.update).toHaveBeenCalledWith({
        fileId: existingFileId,
        media: {
          mimeType: 'application/json',
          body: JSON.stringify(mockRequestBody),
        },
      });
      expect(mockDriveFiles.create).not.toHaveBeenCalled();
    });

    it('should return 500 if Drive API fails during create', async () => {
      const mockRequestBody = { vehicles: [{ id: 'new', make: 'NewCar' }] };

      mockFindFile.mockResolvedValueOnce(null);

      // Use the existing mock function
      mockDriveFiles.create.mockRejectedValueOnce(new Error('Drive API create error'));

      const req = createMockRequest('POST', mockRequestBody);
      const response = await POST(req);
      const jsonResponse = await response.json();

      expect(response.status).toBe(500);
      // The actual route returns just the error message in the 'error' field for 500s from catch blocks
      expect(jsonResponse).toEqual({ error: 'Drive API create error' });
      expect(getDriveService).toHaveBeenCalled();
      expect(mockFindFile).toHaveBeenCalledWith(expect.objectContaining({ files: mockDriveFiles }), 'OwnAutoCare.json');
      expect(mockDriveFiles.create).toHaveBeenCalled();
      expect(mockDriveFiles.update).not.toHaveBeenCalled();
    });

    it('should return 500 if Drive API fails during update', async () => {
      const mockRequestBody = { vehicles: [{ id: 'updated', make: 'UpdatedCar' }] };
      const existingFileId = 'existing-file-id';

      mockFindFile.mockResolvedValueOnce(existingFileId);

      // Use the existing mock function
      mockDriveFiles.update.mockRejectedValueOnce(new Error('Drive API update error'));

      const req = createMockRequest('POST', mockRequestBody);
      const response = await POST(req);
      const jsonResponse = await response.json();

      expect(response.status).toBe(500);
      // The actual route returns just the error message in the 'error' field for 500s from catch blocks
      expect(jsonResponse).toEqual({ error: 'Drive API update error' });
      expect(getDriveService).toHaveBeenCalled();
      expect(mockFindFile).toHaveBeenCalledWith(expect.objectContaining({ files: mockDriveFiles }), 'OwnAutoCare.json');
      expect(mockDriveFiles.update).toHaveBeenCalled();
      expect(mockDriveFiles.create).not.toHaveBeenCalled();
    });
  });
});

// TODO: Fix GET tests if time permits, focusing on mockDriveFiles.get implementation
// For GET success:
// mockDriveFiles.get.mockImplementation(() => Promise.resolve({
//   data: Readable.from(JSON.stringify(mockFileContent)),
//   status: 200,
// }));
// For GET 500:
// mockDriveFiles.get.mockRejectedValueOnce(new Error('Drive API error'));
