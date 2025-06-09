import { google } from 'googleapis';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/app/api/auth/[...nextauth]/route'; // Adjusted path

export async function getDriveService() {
  const session = await getServerSession(authOptions);
  if (!session || !session.accessToken) {
    throw new Error('Not authenticated or access token missing');
  }

  const auth = new google.auth.OAuth2();
  auth.setCredentials({ access_token: session.accessToken });

  return google.drive({ version: 'v3', auth });
}
