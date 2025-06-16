'use client';

import { Button } from '@/components/Button';
import { GoogleLoginButton } from '@/components/GoogleLoginButton';
import { useSession, signOut } from 'next-auth/react';
import { useState } from 'react';

export default function Home() {
  const { data: session } = useSession();
  const [count, setCount] = useState(0);

  const handleIncrement = () => {
    setCount((prev) => prev + 1);
  };

  const handleDecrement = () => {
    setCount((prev) => prev - 1);
  };

  return (
    <main className="min-h-screen flex flex-col items-center justify-center p-24">
      <h1 className="text-4xl font-bold mb-8">Next.js Debugging Example</h1>

      {session ? (
        <div className="flex flex-col items-center gap-4">
          <p className="text-xl">Bienvenido, {session.user?.name}</p>
          <Button onClick={() => signOut()} variant="secondary">
            Cerrar sesión
          </Button>
          <div className="mt-8">
            <p className="text-2xl mb-4">Count: {count}</p>
            <div className="flex gap-4">
              <Button onClick={handleDecrement} variant="secondary">
                Decrement
              </Button>
              <Button onClick={handleIncrement}>Increment</Button>
            </div>
          </div>
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