import Link from 'next/link';
export default function Layout({ children }) {
  return (
    <div className='relative flex size-full min-h-screen flex-col bg-gray-50 justify-between group/design-root overflow-x-hidden'>
      <header className='bg-gray-100 p-4 text-center'>
        {/* This header might be dynamic per page, handled within each page or a nested layout */}
      </header>
      <main className='flex-grow p-4'>{children}</main>
      <nav className='flex gap-2 border-t border-[#eaedf1] bg-gray-50 px-4 pb-3 pt-2'>
        <Link href='/' className='flex flex-1 flex-col items-center justify-end gap-1 rounded-full text-[#101518]'>
          {/* SVG Icon Placeholder */} Garage
        </Link>
        <Link href='/search' className='flex flex-1 flex-col items-center justify-end gap-1 rounded-full text-[#5c748a]'>
          {/* SVG Icon Placeholder */} Search
        </Link>
        <Link href='/profile' className='flex flex-1 flex-col items-center justify-end gap-1 rounded-full text-[#5c748a]'>
          {/* SVG Icon Placeholder */} Profile
        </Link>
      </nav>
      <div className='h-5 bg-gray-50'></div> {/* This was in Garage.html, assuming part of common footer */}
    </div>
  );
}
