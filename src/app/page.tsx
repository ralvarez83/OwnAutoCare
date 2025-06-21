'use client';

import { Button } from '@/components/Button';
import { GoogleLoginButton } from '@/components/GoogleLoginButton';
import { useSession, signOut } from 'next-auth/react';
import { useState } from 'react';
import Link from 'next/link';

export default function Home() {
  const { data: session } = useSession();
  const [count, setCount] = useState(0);
  const [uploadStatus, setUploadStatus] = useState<string>('');

  const handleIncrement = () => {
    setCount(prev => prev + 1);
  };

  const handleDecrement = () => {
    setCount(prev => prev - 1);
  };

  const handleUpload = async () => {
    try {
      const testObject = {
        test: 'data',
        timestamp: Date.now(),
        nested: {
          field: 'value',
          numbers: [1, 2, 3],
        },
      };

      const response = await fetch('/api/upload', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(testObject),
      });
      const data = await response.json();

      if (data.success) {
        setUploadStatus('File uploaded successfully!');
      } else {
        setUploadStatus('Error uploading file');
      }
    } catch (error) {
      setUploadStatus('Error uploading file');
      console.error('Error:', error);
    }
  };

  return (
    <main className="min-h-screen flex flex-col items-center justify-center p-24 pt-32">
      <h1 className="text-4xl font-bold mb-8">OwnAutoCare</h1>
      <p className="text-xl text-gray-600 mb-8">Gestión de mantenimiento de vehículos</p>

      {session ? (
        <div className="flex flex-col items-center gap-4">
          <p className="text-xl">Bienvenido, {session.user?.name}</p>

          <div className="flex gap-4 mb-8">
            <Link href="/vehicles">
              <Button size="lg">🚗 Gestionar Vehículos</Button>
            </Link>
            <Button onClick={() => signOut()} variant="secondary">
              Cerrar sesión
            </Button>
          </div>

          <div className="mt-8">
            <p className="text-2xl mb-4">Count: {count}</p>
            <div className="flex gap-4">
              <Button onClick={handleDecrement} variant="secondary">
                Decrement
              </Button>
              <Button onClick={handleIncrement}>Increment</Button>
            </div>
          </div>
          <button
            onClick={handleUpload}
            className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
          >
            Upload Test File to Google Drive
          </button>
          {uploadStatus && <p className="mt-4 text-center">{uploadStatus}</p>}
        </div>
      ) : (
        <div className="flex flex-col items-center gap-4">
          <p className="text-xl mb-4">Por favor, inicia sesión para continuar</p>
          <GoogleLoginButton />
        </div>
      )}
    </main>
  );
}
