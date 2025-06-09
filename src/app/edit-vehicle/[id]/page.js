'use client';
import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { useData } from '@/context/DataContext';
import { Vehicle } from '@/types';
import Link from 'next/link';

export default function EditVehiclePage() {
  const { getVehicleById, updateVehicle } = useData();
  const router = useRouter();
  const params = useParams();
  const vehicleId = typeof params.id === 'string' ? params.id : '';

  const [make, setMake] = useState('');
  const [model, setModel] = useState('');
  const [year, setYear] = useState<number | ''>('');
  const [vin, setVin] = useState('');
  const [photoUrl, setPhotoUrl] = useState('');
  const [currentMileage, setCurrentMileage] = useState<number | ''>('');
  const [oilChangeMileageInterval, setOilChangeMileageInterval] = useState<number | ''>('');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (vehicleId) {
      const vehicle = getVehicleById(vehicleId);
      if (vehicle) {
        setMake(vehicle.make);
        setModel(vehicle.model);
        setYear(vehicle.year);
        setVin(vehicle.vin || '');
        setPhotoUrl(vehicle.photoUrl || '');
        setCurrentMileage(vehicle.currentMileage || '');
        setOilChangeMileageInterval(vehicle.oilChangeMileageInterval || '');
      } else {
        // Handle vehicle not found, maybe redirect or show error
        router.push('/'); // Simple redirect for now
      }
      setIsLoading(false);
    }
  }, [vehicleId, getVehicleById, router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!make || !model || !year) {
      alert('Please fill in at least Make, Model, and Year.');
      return;
    }
    const updatedVehicleData: Vehicle = {
      id: vehicleId, // Crucial for update
      make,
      model,
      year: Number(year),
      vin,
      photoUrl,
      currentMileage: currentMileage !== '' ? Number(currentMileage) : undefined,
      oilChangeMileageInterval: oilChangeMileageInterval !== '' ? Number(oilChangeMileageInterval) : undefined,
    };
    await updateVehicle(updatedVehicleData);
    router.push(`/vehicles/${vehicleId}`); // Navigate to vehicle details page
  };

  if (isLoading) return <p>Loading vehicle data...</p>;
  if (!vehicleId) return <p>No vehicle ID specified.</p>;


  return (
    <div className='p-4'>
      <Link href={`/vehicles/${vehicleId}`} className='text-indigo-600 hover:text-indigo-800 mb-4 block'>&larr; Back to Vehicle Details</Link>
      <h1 className='text-lg font-bold mb-4'>Edit Vehicle</h1>
      <form onSubmit={handleSubmit} className='space-y-4'>
        {/* Form fields identical to AddVehiclePage, pre-filled with vehicle data */}
        <div>
          <label htmlFor='make'>Make</label>
          <input type='text' id='make' value={make} onChange={e => setMake(e.target.value)} required className='mt-1 block w-full p-2 border rounded'/>
        </div>
        <div>
          <label htmlFor='model'>Model</label>
          <input type='text' id='model' value={model} onChange={e => setModel(e.target.value)} required className='mt-1 block w-full p-2 border rounded'/>
        </div>
        <div>
          <label htmlFor='year'>Year</label>
          <input type='number' id='year' value={year} onChange={e => setYear(Number(e.target.value))} required className='mt-1 block w-full p-2 border rounded'/>
        </div>
        <div>
          <label htmlFor='currentMileage'>Current Mileage (km)</label>
          <input type='number' id='currentMileage' value={currentMileage} onChange={e => setCurrentMileage(Number(e.target.value))} className='mt-1 block w-full p-2 border rounded'/>
        </div>
        <div>
          <label htmlFor='vin'>VIN</label>
          <input type='text' id='vin' value={vin} onChange={e => setVin(e.target.value)} className='mt-1 block w-full p-2 border rounded'/>
        </div>
        <div>
          <label htmlFor='photoUrl'>Photo URL</label>
          <input type='text' id='photoUrl' value={photoUrl} onChange={e => setPhotoUrl(e.target.value)} className='mt-1 block w-full p-2 border rounded'/>
        </div>
        <div>
          <label htmlFor='oilChangeMileageInterval'>Oil Change Interval (km)</label>
          <input type='number' id='oilChangeMileageInterval' value={oilChangeMileageInterval} onChange={e => setOilChangeMileageInterval(Number(e.target.value))} className='mt-1 block w-full p-2 border rounded'/>
        </div>
        <button type='submit' className='w-full py-2 px-4 bg-indigo-600 text-white rounded hover:bg-indigo-700'>Save Changes</button>
      </form>
    </div>
  );
}
