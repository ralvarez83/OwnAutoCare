import { Inter } from 'next/font/google';
import './globals.css';
import Providers from './providers';
import { Navigation } from '@/components/Navigation';

const inter = Inter({ subsets: ['latin'] });

export const metadata = {
  title: 'OwnAutoCare - Gestión de Mantenimiento de Vehículos',
  description:
    'Aplicación para gestionar el mantenimiento de tus vehículos de forma sencilla y eficiente',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body className={inter.className}>
        <Providers>
          <Navigation />
          {children}
        </Providers>
      </body>
    </html>
  );
}
