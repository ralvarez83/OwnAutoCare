import request from 'supertest';
import { createServer } from 'http';
import { NextApiRequest, NextApiResponse } from 'next';
import { GET, POST } from '../vehicles/route';
import { PUT, DELETE } from '../vehicles/[id]/route';

// Mock NextAuth
jest.mock('next-auth', () => ({
  getServerSession: jest.fn(() => ({
    user: {
      name: 'Test User',
      email: 'test@example.com',
    },
    accessToken: 'mock-access-token',
  })),
}));

// Mock Google Drive API
jest.mock('googleapis', () => ({
  google: {
    drive: jest.fn(() => ({
      files: {
        create: jest.fn().mockResolvedValue({
          data: {
            id: 'mock-file-id',
            name: 'mock-file-name.json',
            webViewLink: 'https://drive.google.com/file/d/mock-file-id/view',
          },
        }),
        list: jest.fn().mockResolvedValue({
          data: {
            files: [
              {
                id: 'mock-file-id',
                name: 'vehicle-test-uuid-123.json',
              },
            ],
          },
        }),
        get: jest.fn().mockResolvedValue({
          data: {
            id: 'mock-file-id',
            name: 'vehicle-test-uuid-123.json',
          },
        }),
        update: jest.fn().mockResolvedValue({
          data: {
            id: 'mock-file-id',
            name: 'vehicle-test-uuid-123.json',
          },
        }),
        delete: jest.fn().mockResolvedValue({}),
      },
    })),
  },
}));

describe('Vehicles API E2E', () => {
  let server: any;

  beforeAll(() => {
    // Create a simple server for testing
    server = createServer(async (req: any, res: any) => {
      const url = new URL(req.url!, `http://${req.headers.host}`);

      if (req.method === 'GET' && url.pathname === '/api/vehicles') {
        await GET(req as NextApiRequest, res as NextApiResponse);
      } else if (req.method === 'POST' && url.pathname === '/api/vehicles') {
        await POST(req as NextApiRequest, res as NextApiResponse);
      } else if (req.method === 'PUT' && url.pathname.startsWith('/api/vehicles/')) {
        const id = url.pathname.split('/').pop();
        await PUT(req as NextApiRequest, { params: Promise.resolve({ id }) } as any);
      } else if (req.method === 'DELETE' && url.pathname.startsWith('/api/vehicles/')) {
        const id = url.pathname.split('/').pop();
        await DELETE(req as NextApiRequest, { params: Promise.resolve({ id }) } as any);
      } else {
        res.writeHead(404);
        res.end('Not Found');
      }
    });
  });

  afterAll(() => {
    server.close();
  });

  describe('GET /api/vehicles', () => {
    it('should return all vehicles', async () => {
      const response = await request(server).get('/api/vehicles').expect(200);

      expect(response.body).toHaveProperty('success', true);
      expect(response.body).toHaveProperty('vehicles');
      expect(Array.isArray(response.body.vehicles)).toBe(true);
    });

    it('should return 401 when not authenticated', async () => {
      // Mock unauthenticated session
      jest.mocked(require('next-auth').getServerSession).mockResolvedValueOnce(null);

      const response = await request(server).get('/api/vehicles').expect(401);

      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('message', 'Authentication required');
    });
  });

  describe('POST /api/vehicles', () => {
    it('should create a new vehicle', async () => {
      const vehicleData = {
        marca: 'Toyota',
        modelo: 'Corolla',
        kms: 50000,
        kmsCambioAceite: 5000,
        tipoAceite: '5W-30',
        tipoDistribucion: 'cadena',
      };

      const response = await request(server).post('/api/vehicles').send(vehicleData).expect(200);

      expect(response.body).toHaveProperty('success', true);
      expect(response.body).toHaveProperty('message', 'Vehicle created successfully');
      expect(response.body).toHaveProperty('vehicle');
      expect(response.body).toHaveProperty('fileId');
      expect(response.body).toHaveProperty('fileLink');

      expect(response.body.vehicle).toMatchObject({
        marca: vehicleData.marca,
        modelo: vehicleData.modelo,
        kms: vehicleData.kms,
        kmsCambioAceite: vehicleData.kmsCambioAceite,
        tipoAceite: vehicleData.tipoAceite,
        tipoDistribucion: vehicleData.tipoDistribucion,
      });
    });

    it('should create a vehicle with correa distribution', async () => {
      const vehicleData = {
        marca: 'Honda',
        modelo: 'Civic',
        kms: 60000,
        kmsCambioAceite: 6000,
        tipoAceite: '10W-40',
        tipoDistribucion: 'correa',
        kmsCambioCorrea: 120000,
      };

      const response = await request(server).post('/api/vehicles').send(vehicleData).expect(200);

      expect(response.body.vehicle).toMatchObject({
        marca: vehicleData.marca,
        modelo: vehicleData.modelo,
        kmsCambioCorrea: vehicleData.kmsCambioCorrea,
        tipoDistribucion: 'correa',
      });
    });

    it('should return 400 for invalid vehicle data', async () => {
      const invalidData = {
        marca: '',
        modelo: '',
        kms: -1,
      };

      const response = await request(server).post('/api/vehicles').send(invalidData).expect(400);

      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('message', 'Invalid vehicle data');
    });

    it('should return 401 when not authenticated', async () => {
      // Mock unauthenticated session
      jest.mocked(require('next-auth').getServerSession).mockResolvedValueOnce(null);

      const response = await request(server)
        .post('/api/vehicles')
        .send({ marca: 'Test' })
        .expect(401);

      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('message', 'Authentication required');
    });

    it('should return 401 when access token is missing', async () => {
      // Mock session without access token
      jest.mocked(require('next-auth').getServerSession).mockResolvedValueOnce({
        user: { name: 'Test User' },
        // No accessToken
      });

      const response = await request(server)
        .post('/api/vehicles')
        .send({ marca: 'Test' })
        .expect(401);

      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('message', 'Google Drive access token not available');
    });
  });

  describe('PUT /api/vehicles/[id]', () => {
    it('should update a vehicle', async () => {
      const updateData = {
        marca: 'Updated Toyota',
        kms: 60000,
      };

      const response = await request(server)
        .put('/api/vehicles/test-uuid-123')
        .send(updateData)
        .expect(200);

      expect(response.body).toHaveProperty('success', true);
      expect(response.body).toHaveProperty('message', 'Vehicle updated successfully');
      expect(response.body).toHaveProperty('vehicle');
    });

    it('should return 400 for invalid update data', async () => {
      const invalidData = {
        kms: -1,
      };

      const response = await request(server)
        .put('/api/vehicles/test-uuid-123')
        .send(invalidData)
        .expect(400);

      expect(response.body).toHaveProperty('success', false);
    });
  });

  describe('DELETE /api/vehicles/[id]', () => {
    it('should delete a vehicle', async () => {
      const response = await request(server).delete('/api/vehicles/test-uuid-123').expect(200);

      expect(response.body).toHaveProperty('success', true);
      expect(response.body).toHaveProperty('message', 'Vehicle deleted successfully');
    });
  });
});
