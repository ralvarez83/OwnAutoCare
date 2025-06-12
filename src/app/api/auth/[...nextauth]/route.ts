import NextAuth, { type AuthOptions, Profile, Account, User } from 'next-auth';
import { JWT } from 'next-auth/jwt';
import GoogleProvider from 'next-auth/providers/google';

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
    async jwt({ token, account, profile }: { token: JWT; account?: Account | null; profile?: Profile | User | null }): Promise<JWT> {
      // En el primer inicio de sesión, 'account' y 'profile' están disponibles.
      if (account && account.access_token) {
        token.accessToken = account.access_token;
      }
      if (profile) {
        // 'profile' de Google contiene name, email, picture.
        // Aseguramos que estos se añadan al token JWT.
        token.name = profile.name;
        token.email = profile.email;
        // Google profile.picture, NextAuth session.user.image
        // El tipo Profile de next-auth no siempre tiene 'picture', así que usamos una aserción de tipo o accedemos de forma segura.
        token.picture = (profile as any).picture || (profile as any).image;
      }
      return token;
    },
    async session({ session, token }: { session: any; token: JWT }): Promise<any> {
      // El token JWT (modificado arriba) se usa para construir el objeto de sesión.
      // Pasamos el accessToken y la información del perfil del token a la sesión.
      if (token.accessToken) {
        session.accessToken = token.accessToken as string;
      }
      // Aseguramos que session.user tenga la información del perfil del token.
      // NextAuth v4 típicamente ya mapea name, email, image al session.user si están en el token.
      // Esta es una confirmación explícita.
      if (token.name) session.user.name = token.name;
      if (token.email) session.user.email = token.email;
      if (token.picture) session.user.image = token.picture as string;

      return session;
    },
  },
};

const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
