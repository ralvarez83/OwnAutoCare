import { google, drive_v3 } from 'googleapis';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/app/api/auth/[...nextauth]/route';
import { Session } from 'next-auth'; // Import Session type

// Augment session type locally or define a more specific one for your needs
interface SessionWithToken extends Session {
  accessToken?: string;
}

export async function getDriveService(): Promise<drive_v3.Drive> {
  const session = await getServerSession(authOptions) as SessionWithToken | null;

  if (!session || !session.accessToken) {
    throw new Error('Not authenticated or access token missing in session');
  }

  const auth = new google.auth.OAuth2();
  auth.setCredentials({ access_token: session.accessToken });

  return google.drive({ version: 'v3', auth });
}
