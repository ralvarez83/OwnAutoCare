'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useData } from '@/context/DataContext';
import { Vehicle } from '@/types';

export default function AddVehiclePage() {
  const { addVehicle } = useData();
  const router = useRouter();
  const [make, setMake] = useState('');
  const [model, setModel] = useState('');
  const [year, setYear] = useState<number | ''>('');
  const [vin, setVin] = useState('');
  const [photoUrl, setPhotoUrl] = useState('');
  const [currentMileage, setCurrentMileage] = useState<number | ''>('');
  const [oilChangeMileageInterval, setOilChangeMileageInterval] = useState<number | ''>('');


  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!make || !model || !year) {
      alert('Please fill in at least Make, Model, and Year.');
      return;
    }
    const newVehicleData: Omit<Vehicle, 'id'> = {
      make,
      model,
      year: Number(year),
      vin,
      photoUrl,
      currentMileage: currentMileage !== '' ? Number(currentMileage) : undefined,
      oilChangeMileageInterval: oilChangeMileageInterval !== '' ? Number(oilChangeMileageInterval) : undefined,
    };
    await addVehicle(newVehicleData);
    router.push('/');
  };

  return (
    <div className='p-4'>
      <h1 className='text-lg font-bold mb-4'>Add New Vehicle</h1>
      <form onSubmit={handleSubmit} className='space-y-4' noValidate>
        {/* Make, Model, Year, VIN, PhotoURL inputs from previous step... */}
        <div>
          <label htmlFor='make' className='block text-sm font-medium text-gray-700'>Make</label>
          <input type='text' id='make' value={make} onChange={e => setMake(e.target.value)} required
                 className='mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm' />
        </div>
        <div>
          <label htmlFor='model' className='block text-sm font-medium text-gray-700'>Model</label>
          <input type='text' id='model' value={model} onChange={e => setModel(e.target.value)} required
                 className='mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm' />
        </div>
        <div>
          <label htmlFor='year' className='block text-sm font-medium text-gray-700'>Year</label>
          <input type='number' id='year' value={year} onChange={e => setYear(Number(e.target.value))} required
                 className='mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm' />
        </div>
         <div>
          <label htmlFor='currentMileage' className='block text-sm font-medium text-gray-700'>Current Mileage (km)</label>
          <input type='number' id='currentMileage' value={currentMileage} onChange={e => setCurrentMileage(Number(e.target.value))}
                 className='mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm' />
        </div>
        <div>
          <label htmlFor='vin' className='block text-sm font-medium text-gray-700'>VIN</label>
          <input type='text' id='vin' value={vin} onChange={e => setVin(e.target.value)}
                 className='mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm' />
        </div>
        <div>
          <label htmlFor='photoUrl' className='block text-sm font-medium text-gray-700'>Photo URL (optional)</label>
          <input type='text' id='photoUrl' value={photoUrl} onChange={e => setPhotoUrl(e.target.value)}
                 className='mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm' />
        </div>
        <div>
          <label htmlFor='oilChangeMileageInterval' className='block text-sm font-medium text-gray-700'>Oil Change Interval (km, optional)</label>
          <input type='number' id='oilChangeMileageInterval' value={oilChangeMileageInterval} onChange={e => setOilChangeMileageInterval(Number(e.target.value))}
                 className='mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm' />
        </div>
        <button type='submit'
                className='w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500'>
          Save Vehicle
        </button>
      </form>
    </div>
  );
}
