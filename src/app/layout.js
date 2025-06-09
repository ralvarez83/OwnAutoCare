import Layout from '@/components/Layout';
import AuthProvider from '@/components/providers/AuthProvider';
import { DataProvider } from '@/context/DataContext'; // Import DataProvider
import './globals.css';

export const metadata = {
  title: 'OwnAutoCare',
  description: 'Manage your vehicle maintenance',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang='en'>
      <head>
        <link rel='preconnect' href='https://fonts.gstatic.com' crossOrigin='anonymous' />
        <link
          rel='stylesheet'
          href='https://fonts.googleapis.com/css2?display=swap&family=Noto+Sans:wght@400;500;700;900&family=Space+Grotesk:wght@400;500;700'
        />
      </head>
      <body style={{ fontFamily: '"Space Grotesk", "Noto Sans", sans-serif' }}>
        <AuthProvider>
          <DataProvider> {/* Wrap Layout with DataProvider */}
            <Layout>{children}</Layout>
          </DataProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
