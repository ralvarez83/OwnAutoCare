import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { authOptions } from '../auth/authOptions';
import { Vehicle, CreateVehicleData, UpdateVehicleData } from '@/types/vehicle';
import { google } from 'googleapis';

// GET - Obtener todos los vehículos desde Google Drive
export async function GET() {
  try {
    const session = await getServerSession(authOptions);

    if (!session) {
      return NextResponse.json(
        { success: false, message: 'Authentication required' },
        { status: 401 }
      );
    }

    // Por ahora devolvemos un array vacío
    // En el futuro implementaremos la lectura desde Google Drive
    return NextResponse.json({
      success: true,
      vehicles: [],
    });
  } catch (error) {
    console.error('Error getting vehicles:', error);
    return NextResponse.json(
      { success: false, message: 'Error getting vehicles' },
      { status: 500 }
    );
  }
}

// POST - Crear un nuevo vehículo en Google Drive
export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);

    if (!session) {
      return NextResponse.json(
        { success: false, message: 'Authentication required' },
        { status: 401 }
      );
    }

    // Verificar que tenemos el token de acceso
    if (!session.accessToken) {
      return NextResponse.json(
        { success: false, message: 'Google Drive access token not available' },
        { status: 401 }
      );
    }

    const vehicleData: CreateVehicleData = await request.json();

    if (!vehicleData || typeof vehicleData !== 'object') {
      return NextResponse.json(
        { success: false, message: 'Invalid vehicle data' },
        { status: 400 }
      );
    }

    // Crear el vehículo con ID y fechas
    const newVehicle: Vehicle = {
      id: crypto.randomUUID(),
      ...vehicleData,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // Crear un archivo JSON con los datos del vehículo
    const fileName = `vehicle-${newVehicle.id}.json`;
    const fileContent = JSON.stringify(newVehicle, null, 2);

    console.log('Creating file in Google Drive:', fileName);
    console.log('Access token available:', !!session.accessToken);
    console.log('Access token length:', session.accessToken?.length);
    console.log('Session data:', {
      hasAccessToken: !!session.accessToken,
      hasRefreshToken: !!(session as any).refreshToken,
      expiresAt: (session as any).expiresAt,
    });

    // Configurar Google Drive API con más opciones
    const drive = google.drive({
      version: 'v3',
      headers: {
        Authorization: `Bearer ${session.accessToken}`,
        'Content-Type': 'application/json',
      },
    });

    const fileMetadata = {
      name: fileName,
      parents: [], // Se guardará en la raíz de Google Drive
      mimeType: 'application/json',
    };

    const media = {
      mimeType: 'application/json',
      body: fileContent, // No codificar en base64
    };

    console.log('Attempting to create file with metadata:', fileMetadata);

    const response = await drive.files.create({
      requestBody: fileMetadata,
      media: media,
      fields: 'id,name,webViewLink',
    });

    console.log('File created successfully:', response.data);

    return NextResponse.json({
      success: true,
      message: 'Vehicle created successfully',
      vehicle: newVehicle,
      fileId: response.data.id,
      fileLink: response.data.webViewLink,
    });
  } catch (error) {
    console.error('Error creating vehicle:', error);

    // Manejar errores específicos de Google Drive
    if (error && typeof error === 'object' && 'code' in error && error.code === 401) {
      return NextResponse.json(
        { success: false, message: 'Google Drive authentication failed. Please sign in again.' },
        { status: 401 }
      );
    }

    return NextResponse.json(
      { success: false, message: 'Error creating vehicle' },
      { status: 500 }
    );
  }
}
