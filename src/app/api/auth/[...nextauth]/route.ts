import NextAuth, { type AuthOptions } from 'next-auth';
import GoogleProvider from 'next-auth/providers/google';

// Define a custom session type if needed to include accessToken
// interface CustomSession extends Session {
//   accessToken?: string;
// }

export const authOptions: AuthOptions = {
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
      authorization: {
        params: {
          scope: 'openid email profile https://www.googleapis.com/auth/drive.appdata',
        },
      },
    }),
  ],
  secret: process.env.NEXTAUTH_SECRET,
  callbacks: {
    async jwt({ token, account }) {
      if (account && account.access_token) {
        token.accessToken = account.access_token;
      }
      // token.idToken = account?.id_token; // Persist id_token if needed
      return token;
    },
    async session({ session, token }) {
      // Pass accessToken to the session client-side
      // Note: Default session type might not have accessToken.
      // You might need to augment NextAuth.Session type or use a type assertion.
      if (token.accessToken) {
        (session as any).accessToken = token.accessToken;
      }
      // (session as any).idToken = token.idToken; // Pass id_token if needed
      return session;
    },
  },
};

const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
