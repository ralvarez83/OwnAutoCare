import React, { ReactNode } from 'react';
import Link from 'next/link';

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <div className='relative flex size-full min-h-screen flex-col bg-gray-50 justify-between group/design-root overflow-x-hidden'>
      <header className='bg-gray-100 p-4 text-center hidden'> {/* Example: Hide header for now if not designed */}
        <p>App Header Placeholder (Hidden)</p>
      </header>
      <main className='flex-grow'>{children}</main> {/* Removed p-4 to allow pages to control their own padding */}
      <nav className='flex gap-2 border-t border-[#eaedf1] bg-gray-50 px-4 pb-3 pt-2'>
        <Link href='/' className='flex flex-1 flex-col items-center justify-end gap-1 rounded-full text-[#101518]'>
          {/* SVG Icon Placeholder for Garage */}
          Garage
        </Link>
        <Link href='/search' className='flex flex-1 flex-col items-center justify-end gap-1 rounded-full text-[#5c748a]'>
          {/* SVG Icon Placeholder for Search */}
          Search
        </Link>
        <Link href='/profile' className='flex flex-1 flex-col items-center justify-end gap-1 rounded-full text-[#5c748a]'>
          {/* SVG Icon Placeholder for Profile */}
          Profile
        </Link>
      </nav>
      {/* Removed the extra h-5 div from Garage.html as bottom padding/safe area should be handled by viewport settings or main layout CSS if needed */}
    </div>
  );
}
