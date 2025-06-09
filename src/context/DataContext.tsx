'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode, useCallback } from 'react';
import { useSession } from 'next-auth/react';
import { AppData, Vehicle, MaintenanceRecord } from '@/types'; // Assuming types are in src/types
import { v4 as uuidv4 } from 'uuid';

interface DataContextType {
  appData: AppData;
  loading: boolean;
  error: string | null;
  addVehicle: (vehicle: Omit<Vehicle, 'id'>) => Promise<void>;
  updateVehicle: (vehicle: Vehicle) => Promise<void>;
  deleteVehicle: (vehicleId: string) => Promise<void>;
  getVehicleById: (vehicleId: string) => Vehicle | undefined;
  addMaintenanceRecord: (record: Omit<MaintenanceRecord, 'id'>) => Promise<void>;
  updateMaintenanceRecord: (record: MaintenanceRecord) => Promise<void>;
  deleteMaintenanceRecord: (recordId: string) => Promise<void>;
  getMaintenanceRecordsByVehicleId: (vehicleId: string) => MaintenanceRecord[];
  forceSaveToDrive: () => Promise<void>; // Exposed for explicit save if needed
}

const DataContext = createContext<DataContextType | undefined>(undefined);

const initialAppData: AppData = {
  vehicles: [],
  maintenanceRecords: [],
};

export const DataProvider = ({ children }: { children: ReactNode }) => {
  const { data: session, status } = useSession();
  const [appData, setAppData] = useState<AppData>(initialAppData);
  const [loading, setLoading] = useState<boolean>(true); // For initial load
  const [error, setError] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState<boolean>(false); // Prevent concurrent saves
  const [saveQueued, setSaveQueued] = useState<boolean>(false); // Queue a save if one is in progress

  const loadDataFromDrive = useCallback(async () => {
    if (status !== 'authenticated' || !session) {
      setLoading(false);
      setAppData(initialAppData); // Reset if not authenticated
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const response = await fetch('/api/drive/file-ops');
      if (response.ok) {
        const data = await response.json();
        setAppData(data || initialAppData);
      } else if (response.status === 404) {
        setAppData(initialAppData); // No file yet, start fresh
        // Optionally, save initial empty state to Drive here
        // await saveDataToDrive(initialAppData);
      } else {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to load data from Drive');
      }
    } catch (e: any) {
      console.error('Error loading data from Drive:', e);
      setError(e.message);
      setAppData(initialAppData); // Fallback to initial state on error
    } finally {
      setLoading(false);
    }
  }, [session, status]);

  useEffect(() => {
    loadDataFromDrive();
  }, [loadDataFromDrive]);

  const saveDataToDrive = useCallback(async (currentData: AppData) => {
    if (status !== 'authenticated' || isSaving) {
      if(isSaving) setSaveQueued(true); // Queue if already saving
      return;
    }
    setIsSaving(true);
    setError(null);
    try {
      const response = await fetch('/api/drive/file-ops', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(currentData),
      });
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to save data to Drive');
      }
      // console.log('Data saved to Drive');
    } catch (e: any) {
      console.error('Error saving data to Drive:', e);
      setError(e.message);
    } finally {
      setIsSaving(false);
      if(saveQueued) {
        setSaveQueued(false);
        saveDataToDrive(appData); // Process queued save with latest appData
      }
    }
  }, [status, isSaving, saveQueued, appData]); // appData dependency for queued save

  // Debounced save function
  const debouncedSave = useCallback(
    (newData: AppData) => {
      // Basic debounce: use a timeout to delay save.
      // More robust debounce could be implemented if needed.
      const handler = setTimeout(() => {
        saveDataToDrive(newData);
      }, 1000); // Save 1 second after the last change
      return () => clearTimeout(handler);
    },
    [saveDataToDrive]
  );


  // CRUD Operations
  const addVehicle = async (vehicleData: Omit<Vehicle, 'id'>) => {
    const newVehicle: Vehicle = { ...vehicleData, id: uuidv4() };
    const newData = { ...appData, vehicles: [...appData.vehicles, newVehicle] };
    setAppData(newData);
    debouncedSave(newData);
  };

  const updateVehicle = async (updatedVehicle: Vehicle) => {
    const newData = {
      ...appData,
      vehicles: appData.vehicles.map(v => v.id === updatedVehicle.id ? updatedVehicle : v),
    };
    setAppData(newData);
    debouncedSave(newData);
  };

  const deleteVehicle = async (vehicleId: string) => {
    const newData = {
      ...appData,
      vehicles: appData.vehicles.filter(v => v.id !== vehicleId),
      maintenanceRecords: appData.maintenanceRecords.filter(mr => mr.vehicleId !== vehicleId), // Cascade delete
    };
    setAppData(newData);
    debouncedSave(newData);
  };

  const getVehicleById = (vehicleId: string) => appData.vehicles.find(v => v.id === vehicleId);

  const addMaintenanceRecord = async (recordData: Omit<MaintenanceRecord, 'id'>) => {
    const newRecord: MaintenanceRecord = { ...recordData, id: uuidv4(), itemizedCosts: recordData.itemizedCosts?.map(ic => ({...ic, id: uuidv4()})) || [] };
    const newData = { ...appData, maintenanceRecords: [...appData.maintenanceRecords, newRecord] };
    setAppData(newData);
    debouncedSave(newData);
  };

  const updateMaintenanceRecord = async (updatedRecord: MaintenanceRecord) => {
    const newData = {
      ...appData,
      maintenanceRecords: appData.maintenanceRecords.map(mr => mr.id === updatedRecord.id ? updatedRecord : mr),
    };
    setAppData(newData);
    debouncedSave(newData);
  };

  const deleteMaintenanceRecord = async (recordId: string) => {
    const newData = {
      ...appData,
      maintenanceRecords: appData.maintenanceRecords.filter(mr => mr.id !== recordId),
    };
    setAppData(newData);
    debouncedSave(newData);
  };

  const getMaintenanceRecordsByVehicleId = (vehicleId: string) => {
    return appData.maintenanceRecords.filter(mr => mr.vehicleId === vehicleId).sort((a,b) => new Date(b.date).getTime() - new Date(a.date).getTime());
  };

  const forceSaveToDrive = async () => {
    await saveDataToDrive(appData);
  }

  return (
    <DataContext.Provider value={{
      appData, loading, error,
      addVehicle, updateVehicle, deleteVehicle, getVehicleById,
      addMaintenanceRecord, updateMaintenanceRecord, deleteMaintenanceRecord,
      getMaintenanceRecordsByVehicleId, forceSaveToDrive
    }}>
      {children}
    </DataContext.Provider>
  );
};

export const useData = () => {
  const context = useContext(DataContext);
  if (context === undefined) {
    throw new Error('useData must be used within a DataProvider');
  }
  return context;
};
