'use client';
import { useState, useMemo } from 'react';
import Link from 'next/link';
import { useData } from '@/context/DataContext';
import { MaintenanceRecord, Vehicle } from '@/types';

export default function SearchPage() {
  const { appData, loading, error, getVehicleById } = useData();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilters, setActiveFilters] = useState<string[]>([]); // For future filter chip functionality

  const handleFilterClick = (filterName: string) => {
    // Basic toggle for now, actual filtering logic for chips TBD
    setActiveFilters(prev =>
      prev.includes(filterName) ? prev.filter(f => f !== filterName) : [...prev, filterName]
    );
  };

  const searchResults = useMemo(() => {
    if (!searchQuery.trim()) {
      return []; // No query, no results
    }
    if (loading || !appData) {
      return [];
    }

    const lowerCaseQuery = searchQuery.toLowerCase();

    // For now, searching only in maintenance record descriptions
    // and vehicle make/model/year.
    // This could be expanded.
    return appData.maintenanceRecords.filter(record => {
      const vehicle = getVehicleById(record.vehicleId);
      const vehicleName = vehicle ? `${vehicle.year} ${vehicle.make} ${vehicle.model}`.toLowerCase() : '';

      return (
        record.description.toLowerCase().includes(lowerCaseQuery) ||
        (record.totalCost?.toString().includes(lowerCaseQuery)) ||
        (record.date.includes(lowerCaseQuery)) || // Simple date string search
        vehicleName.includes(lowerCaseQuery)
        // Add more fields to search here, e.g., itemized costs
      );
    });
  }, [searchQuery, appData, loading, getVehicleById]);

  if (error) return <p>Error loading data: {error}</p>;

  const filterChips = ['Date', 'Type', 'Cost', 'Description']; // From Search.html

  return (
    <div className='p-4'>
      <div className='mb-4'>
        {/* Back arrow - assuming navigation is handled by layout or user uses browser back */}
        <h1 className='text-lg font-bold text-center pr-12'>Search</h1> {/* pr-12 for balance like in HTML */}
      </div>

      {/* Search Bar */}
      <div className='px-0 py-3'> {/* px-4 in HTML, but seems page already has p-4 */}
        <label className='flex flex-col min-w-40 h-12 w-full'>
          <div className='flex w-full flex-1 items-stretch rounded-xl h-full bg-[#e7edf4]'>
            <div className='text-[#49749c] flex items-center justify-center pl-4 rounded-l-xl'>
              {/* MagnifyingGlass SVG Placeholder */}
              <svg xmlns='http://www.w3.org/2000/svg' width='24px' height='24px' fill='currentColor' viewBox='0 0 256 256'>
                <path d='M229.66,218.34l-50.07-50.06a88.11,88.11,0,1,0-11.31,11.31l50.06,50.07a8,8,0,0,0,11.32-11.32ZM40,112a72,72,0,1,1,72,72A72.08,72.08,0,0,1,40,112Z'></path>
              </svg>
            </div>
            <input
              type='text'
              placeholder='Search maintenance records...'
              value={searchQuery}
              onChange={e => setSearchQuery(e.target.value)}
              className='form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-r-xl text-[#0d151c] focus:outline-none focus:ring-0 border-none bg-[#e7edf4] h-full placeholder:text-[#49749c] px-4 pl-2 text-base font-normal leading-normal'
            />
          </div>
        </label>
      </div>

      {/* Filter Chips - UI only for now */}
      <div className='flex gap-3 p-0 pb-3 overflow-x-auto'> {/* px-3 in HTML */}
        {filterChips.map(chip => (
          <button
            key={chip}
            onClick={() => handleFilterClick(chip)}
            className={`h-8 shrink-0 items-center justify-center gap-x-2 rounded-full px-4 text-sm font-medium leading-normal ${activeFilters.includes(chip) ? 'bg-blue-500 text-white' : 'bg-[#e7edf4] text-[#0d151c]'}`}
          >
            {chip}
          </button>
        ))}
      </div>

      {loading && searchQuery.trim() && <p>Searching...</p>}

      {/* Results Section */}
      {!loading && searchQuery.trim() && (
        <div>
          <h3 className='text-lg font-bold px-0 pb-2 pt-4'>Results</h3> {/* px-4 in HTML */}
          {searchResults.length === 0 ? (
            <p>No maintenance records found matching your query.</p>
          ) : (
            <ul className='space-y-3'>
              {searchResults.map((record: MaintenanceRecord) => {
                const vehicle = getVehicleById(record.vehicleId);
                return (
                  <li key={record.id} className='p-3 border rounded-md shadow-sm hover:shadow-md transition-shadow'>
                    <Link href={`/vehicles/${record.vehicleId}`} className='block'>
                      <div className='flex justify-between items-start'>
                        <div>
                          <p className='text-[#0d151c] text-base font-medium'>
                            {vehicle ? `${vehicle.year} ${vehicle.make} ${vehicle.model}` : 'Unknown Vehicle'} - {record.date}
                          </p>
                          <p className='text-[#49749c] text-sm line-clamp-2'>{record.description}</p>
                        </div>
                        {record.totalCost !== undefined && (
                          <p className='text-[#0d151c] text-base font-normal shrink-0 ml-2'>${record.totalCost.toFixed(2)}</p>
                        )}
                      </div>
                    </Link>
                  </li>
                );
              })}
            </ul>
          )}
        </div>
      )}
       {searchQuery.trim() === '' && <p className='text-gray-500 pt-4'>Enter a search term to see results.</p>}
    </div>
  );
}
