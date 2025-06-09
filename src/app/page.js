'use client';
import Link from 'next/link';
import { useData } from '@/context/DataContext';
import { Vehicle } from '@/types'; // Assuming types are in src/types

export default function GaragePage() {
  const { appData, loading, error } = useData();

  if (loading) return <p>Loading vehicles...</p>;
  if (error) return <p>Error loading data: {error}</p>;

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '1rem' }}>
        <h1 className='text-lg font-bold'>My Garage</h1>
        <Link href='/add-vehicle' style={{ padding: '0.5rem 1rem', backgroundColor: '#0b80ee', color: 'white', borderRadius: '9999px', textDecoration: 'none' }}>
          + Add Vehicle
        </Link>
      </div>

      <h3 className='text-lg font-bold px-4 pb-2 pt-4'>Vehicles</h3>
      {appData.vehicles.length === 0 ? (
        <p className='px-4'>No vehicles yet. Add one!</p>
      ) : (
        <div className='p-4 grid grid-cols-1 gap-4'>
          {appData.vehicles.map((vehicle: Vehicle) => (
            <Link key={vehicle.id} href={`/vehicles/${vehicle.id}`} className='block p-4 border rounded-xl shadow hover:shadow-lg transition-shadow'>
              <div className='flex items-stretch justify-between gap-4'>
                <div className='flex flex-col gap-1 flex-[2_2_0px]'>
                  {/* Placeholder for last service, adapt from Garage.html */}
                  <p className='text-[#5c748a] text-sm'>Model: {vehicle.model}</p>
                  <p className='text-[#101518] text-base font-bold'>{vehicle.year} {vehicle.make}</p>
                  <p className='text-[#5c748a] text-sm'>VIN: {vehicle.vin || 'N/A'}</p>
                </div>
                {vehicle.photoUrl && (
                  <div
                    className='w-full bg-center bg-no-repeat aspect-video bg-cover rounded-xl flex-1'
                    style={{ backgroundImage: `url(${vehicle.photoUrl})` }}
                  ></div>
                )}
                {!vehicle.photoUrl && (
                  <div className='w-full bg-gray-200 aspect-video rounded-xl flex-1 flex items-center justify-center'>
                    <span className='text-gray-500'>No Image</span>
                  </div>
                )}
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
