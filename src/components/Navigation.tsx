'use client';

import Link from 'next/link';
import { useSession, signOut } from 'next-auth/react';
import { Button } from './Button';

export function Navigation() {
  const { data: session } = useSession();

  return (
    <nav className="bg-white shadow-sm border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center">
            <Link href="/" className="flex items-center space-x-2">
              <span className="text-2xl">🚗</span>
              <span className="text-xl font-bold text-gray-900">OwnAutoCare</span>
            </Link>
          </div>

          {session && (
            <div className="flex items-center space-x-4">
              <Link href="/vehicles">
                <Button variant="secondary" size="sm">
                  Mis Vehículos
                </Button>
              </Link>
              <div className="flex items-center space-x-2">
                <span className="text-sm text-gray-700">{session.user?.name}</span>
                <Button onClick={() => signOut()} variant="secondary" size="sm">
                  Cerrar sesión
                </Button>
              </div>
            </div>
          )}
        </div>
      </div>
    </nav>
  );
}
