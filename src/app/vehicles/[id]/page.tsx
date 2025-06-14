'use client';
import { useMemo } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { useData } from '@/context/DataContext';
import { MaintenanceRecord, Vehicle } from '@/types'; // Ensure Vehicle is imported
import { Bar, Line } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  LineElement,
  PointElement,
  Title,
  Tooltip,
  Legend,
  Filler, // Required for area charts (fill below line)
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  LineElement,
  PointElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

export default function VehicleDetailsPage() {
  const params = useParams();
  const router = useRouter();
  const vehicleId = typeof params.id === 'string' ? params.id : '';
  const { getVehicleById, getMaintenanceRecordsByVehicleId, deleteVehicle, loading, error } = useData();

  const vehicle = getVehicleById(vehicleId);
  // Already sorted by date descending in useData hook
  const maintenanceRecords = getMaintenanceRecordsByVehicleId(vehicleId);

  const handleDeleteVehicle = async () => {
    if (confirm('Are you sure you want to delete this vehicle and all its maintenance records?')) {
      await deleteVehicle(vehicleId);
      router.push('/');
    }
  };

  // Process data for charts
  const chartData = useMemo(() => {
    if (!maintenanceRecords || maintenanceRecords.length === 0) {
      return { labels: [], frequencyData: [], costData: [] };
    }

    const yearlyData: { [year: string]: { count: number; totalCost: number } } = {};

    maintenanceRecords.forEach(record => {
      const year = new Date(record.date).getFullYear().toString();
      if (!yearlyData[year]) {
        yearlyData[year] = { count: 0, totalCost: 0 };
      }
      yearlyData[year].count += 1;
      yearlyData[year].totalCost += record.totalCost || 0;
    });

    const sortedYears = Object.keys(yearlyData).sort((a, b) => parseInt(a) - parseInt(b));
    // Limit to last N years or all years if less than N, e.g., last 5 years
    // const displayYears = sortedYears.slice(-5);
    const displayYears = sortedYears; // For now, show all available years

    return {
      labels: displayYears,
      frequencyData: displayYears.map(year => yearlyData[year].count),
      costData: displayYears.map(year => yearlyData[year].totalCost),
    };
  }, [maintenanceRecords]);

  const frequencyChartOptions = {
    responsive: true,
    plugins: {
      legend: { display: false },
      title: { display: true, text: 'Annual Maintenance Frequency' },
    },
    scales: {
      y: { beginAtZero: true, ticks: { stepSize: 1 } },
    },
  };

  const costChartOptions = {
    responsive: true,
    plugins: {
      legend: { display: false },
      title: { display: true, text: 'Annual Maintenance Costs' },
    },
    scales: {
      y: { beginAtZero: true },
    },
    elements: {
      line: {
        fill: 'start', // To create an area chart
        backgroundColor: 'rgba(75,192,192,0.2)', // Example color
        borderColor: 'rgba(75,192,192,1)',
      }
    }
  };

  const frequencyChartJsData = {
    labels: chartData.labels,
    datasets: [
      {
        label: 'Services',
        data: chartData.frequencyData,
        backgroundColor: 'rgba(53, 162, 235, 0.5)',
      },
    ],
  };

  const costChartJsData = {
    labels: chartData.labels,
    datasets: [
      {
        label: 'Cost ($)',
        data: chartData.costData,
        // fill: true, // already set in options.elements.line.fill
        // backgroundColor: 'rgba(75,192,192,0.2)', // Moved to options
        // borderColor: 'rgba(75,192,192,1)', // Moved to options
      },
    ],
  };


  if (loading) return <p>Loading vehicle details...</p>;
  if (error && !vehicle) return <p>Error: {error}</p>;
  if (!vehicle && !loading) return <p>Vehicle not found.</p>; // Check loading false before concluding not found

  return (
    <div className='p-4'>
      <div className='mb-4'>
        <Link href='/' className='text-indigo-600 hover:text-indigo-800'>&larr; Back to Garage</Link>
      </div>
      {vehicle && (
        <>
          <h1 className='text-2xl font-bold mb-2'>{vehicle.year} {vehicle.make} {vehicle.model}</h1>
          <p><strong>VIN:</strong> {vehicle.vin || 'N/A'}</p>
          <p><strong>License Plate:</strong> {vehicle.licensePlate || 'N/A'}</p>
          {vehicle.photoUrl && <img src={vehicle.photoUrl} alt={`${vehicle.make} ${vehicle.model}`} className='my-4 rounded-lg max-w-sm' />}
          <p><strong>Notes:</strong> {vehicle.notes || 'N/A'}</p>

          {/* <Link href={`/edit-vehicle/${vehicle.id}`} className='text-indigo-600'>Edit Vehicle</Link> */}
          <button onClick={handleDeleteVehicle} className='ml-0 md:ml-4 mt-2 md:mt-0 text-red-600 hover:text-red-800 p-2 rounded border border-red-600 hover:bg-red-50'>Delete Vehicle</button>

          {vehicle && (
            <div className='my-4'>
              <Link href={`/edit-vehicle/${vehicle.id}`}
                    className='text-indigo-600 hover:text-indigo-700 p-2 rounded border border-indigo-600 hover:bg-indigo-50'>
                Edit Vehicle Details
              </Link>
            </div>
          )}

          {/* Add Maintenance Alerts Section */}
          {vehicle && (vehicle.currentMileage !== undefined) && (vehicle.oilChangeMileageInterval !== undefined) && (
            <div className='my-6 p-4 border border-yellow-300 bg-yellow-50 rounded-lg'>
              <h2 className='text-xl font-semibold mb-3 text-yellow-700'>Maintenance Alerts</h2>
              {(function() {
                // Find last oil change
                const oilChangeRecords = maintenanceRecords
                  .filter(r => r.description.toLowerCase().includes('oil change') || r.serviceType?.toLowerCase() === 'oil change')
                  .sort((a,b) => new Date(b.date).getTime() - new Date(a.date).getTime()); // most recent first

                let oilAlert = null;
                if (vehicle.oilChangeMileageInterval && vehicle.currentMileage) {
                  const lastOilChangeKm = oilChangeRecords.length > 0 ? oilChangeRecords[0].kilometers : 0; // Assume 0 if no record
                  const nextOilChangeDueKm = lastOilChangeKm + vehicle.oilChangeMileageInterval;
                  const kmUntilNextOilChange = nextOilChangeDueKm - vehicle.currentMileage;

                  if (kmUntilNextOilChange <= 0) {
                    oilAlert = <p className='text-red-600'><strong>Oil Change Overdue:</strong> Next service was due at {nextOilChangeDueKm} km (currently at {vehicle.currentMileage} km).</p>;
                  } else if (kmUntilNextOilChange <= vehicle.oilChangeMileageInterval * 0.2) { // e.g. within 20% of interval
                    oilAlert = <p className='text-orange-600'><strong>Oil Change Upcoming:</strong> Next service due in {kmUntilNextOilChange} km (at {nextOilChangeDueKm} km).</p>;
                  } else {
                    oilAlert = <p className='text-green-600'>Oil change not due soon. Next at {nextOilChangeDueKm} km.</p>;
                  }
                }
                return oilAlert;
              })()}
              {/* Add more alerts for other service types here */}
            </div>
          )}
        </>
      )}

      <hr className='my-6' />

      <div className='flex justify-between items-center mb-4'>
        <h2 className='text-xl font-semibold'>Maintenance History</h2>
        {vehicle && (
          <Link href={`/new-maintenance?vehicleId=${vehicle.id}`} className='px-4 py-2 bg-green-500 text-white rounded-md hover:bg-green-600'>
            + Add Maintenance
          </Link>
        )}
      </div>
      {maintenanceRecords.length > 0 ? (
        <ul className='space-y-3 mb-8'>
          {maintenanceRecords.map((record: MaintenanceRecord) => (
            <li key={record.id} className='p-3 border rounded-md shadow-sm'>
              <p><strong>Date:</strong> {record.date}</p>
              <p><strong>Description:</strong> {record.description}</p>
              <p><strong>Kilometers:</strong> {record.kilometers} km</p>
              {record.totalCost !== undefined && <p><strong>Cost:</strong> ${record.totalCost.toFixed(2)}</p>}
            </li>
          ))}
        </ul>
      ) : (
        <p className='mb-8'>No maintenance records for this vehicle yet.</p>
      )}

      <div className='mt-8'>
        <h2 className='text-xl font-semibold mb-4'>Maintenance Overview</h2>
        {maintenanceRecords.length > 0 ? (
          <div className='grid grid-cols-1 md:grid-cols-2 gap-8'>
            <div className='p-4 border rounded-lg shadow'>
              <Bar options={frequencyChartOptions} data={frequencyChartJsData} />
            </div>
            <div className='p-4 border rounded-lg shadow'>
              <Line options={costChartOptions} data={costChartJsData} />
            </div>
          </div>
        ) : (
          <p>Not enough data to display charts.</p>
        )}
      </div>
    </div>
  );
}
