'use client';
import { useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation'; // App router hooks
import { useData } from '@/context/DataContext';
import { MaintenanceRecord, ItemizedCost } from '@/types';
import { v4 as uuidv4 } from 'uuid';

export default function NewMaintenancePage() {
  const { addMaintenanceRecord, getVehicleById } = useData();
  const router = useRouter();
  const searchParams = useSearchParams();
  const vehicleId = searchParams.get('vehicleId');

  const [date, setDate] = useState(new Date().toISOString().split('T')[0]); // Default to today
  const [kilometers, setKilometers] = useState<number | ''>('');
  const [description, setDescription] = useState('');
  const [totalCost, setTotalCost] = useState<number | ''>('');
  const [itemizedCosts, setItemizedCosts] = useState<Omit<ItemizedCost, 'id'>[]>([]);
  const [newItemName, setNewItemName] = useState('');
  const [newItemCost, setNewItemCost] = useState<number | ''>('');

  const vehicle = vehicleId ? getVehicleById(vehicleId) : null;

  const handleAddItemizedCost = () => {
    if (newItemName && newItemCost !== '') {
      setItemizedCosts([...itemizedCosts, { name: newItemName, cost: Number(newItemCost) }]);
      setNewItemName('');
      setNewItemCost('');
    }
  };

  const handleRemoveItemizedCost = (indexToRemove: number) => {
    setItemizedCosts(itemizedCosts.filter((_, index) => index !== indexToRemove));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!vehicleId || !date || !kilometers || !description) {
      alert('Please fill in all required fields: Date, Kilometers, Description.');
      return;
    }
    const newRecordData: Omit<MaintenanceRecord, 'id'> = {
      vehicleId,
      date,
      kilometers: Number(kilometers),
      description,
      totalCost: totalCost !== '' ? Number(totalCost) : undefined,
      itemizedCosts: itemizedCosts.map(ic => ({...ic, id: uuidv4()})), // Assign IDs here if not before
    };
    await addMaintenanceRecord(newRecordData);
    router.push(`/vehicles/${vehicleId}`); // Navigate to vehicle details page
  };

  if (!vehicleId) return <p>Vehicle ID not provided. Go back to a vehicle's page to add maintenance.</p>;
  if (!vehicle) return <p>Loading vehicle information or vehicle not found...</p>;

  return (
    <div className='p-4'>
      <h1 className='text-lg font-bold mb-4'>Add New Maintenance for {vehicle.make} {vehicle.model}</h1>
      <form onSubmit={handleSubmit} className='space-y-4'>
        {/* Date, Kilometers, Description - similar to AddVehiclePage inputs */}
        <div>
          <label htmlFor='date'>Date</label>
          <input type='date' id='date' value={date} onChange={e => setDate(e.target.value)} required className='mt-1 block w-full p-2 border rounded'/>
        </div>
        <div>
          <label htmlFor='kilometers'>Kilometers</label>
          <input type='number' id='kilometers' value={kilometers} onChange={e => setKilometers(Number(e.target.value))} required className='mt-1 block w-full p-2 border rounded'/>
        </div>
        <div>
          <label htmlFor='description'>Description</label>
          <textarea id='description' value={description} onChange={e => setDescription(e.target.value)} required className='mt-1 block w-full p-2 border rounded min-h-24'></textarea>
        </div>
        <div>
          <label htmlFor='totalCost'>Total Cost (Optional)</label>
          <input type='number' step='0.01' id='totalCost' value={totalCost} onChange={e => setTotalCost(Number(e.target.value))} className='mt-1 block w-full p-2 border rounded'/>
        </div>

        {/* Itemized Costs Section from NewMantenice.html */}
        <h3 className='text-md font-semibold pt-4'>Itemized Costs (Optional)</h3>
        {itemizedCosts.map((item, index) => (
          <div key={index} className='flex items-center gap-2 p-2 border-b'>
            <span>{item.name}: ${item.cost.toFixed(2)}</span>
            <button type='button' onClick={() => handleRemoveItemizedCost(index)} className='text-red-500 text-xs'>Remove</button>
          </div>
        ))}
        <div className='flex gap-2 items-end mt-2'>
          <input type='text' placeholder='Item Name' value={newItemName} onChange={e => setNewItemName(e.target.value)} className='p-2 border rounded flex-grow'/>
          <input type='number' step='0.01' placeholder='Item Cost' value={newItemCost} onChange={e => setNewItemCost(Number(e.target.value))} className='p-2 border rounded w-24'/>
          <button type='button' onClick={handleAddItemizedCost} className='p-2 bg-blue-500 text-white rounded'>Add Item</button>
        </div>

        <button type='submit' className='w-full mt-6 py-2 px-4 bg-indigo-600 text-white rounded-md hover:bg-indigo-700'>
          Save Maintenance Record
        </button>
      </form>
    </div>
  );
}
