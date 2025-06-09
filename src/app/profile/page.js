'use client';

import { useSession, signIn, signOut } from 'next-auth/react';
import { useState, useEffect } from 'react';

export default function ProfilePage() {
  const { data: session, status } = useSession();
  const [driveStatus, setDriveStatus] = useState('');
  const [driveData, setDriveData] = useState(null);

  useEffect(() => {
    if (session) {
      // Automatically check Drive status on load if session exists
      handleCheckDriveFile();
    }
  }, [session]);

  const handleCheckDriveFile = async () => {
    setDriveStatus('Checking...');
    try {
      const response = await fetch('/api/drive/file-ops');
      if (response.ok) {
        const data = await response.json();
        setDriveData(data);
        setDriveStatus('File found and loaded.');
      } else if (response.status === 404) {
        setDriveStatus('No data file found in Google Drive. Save some data to create it.');
        setDriveData(null);
      } else {
        const errorData = await response.json();
        setDriveStatus(`Error checking file: ${errorData.error || response.statusText}`);
      }
    } catch (error) {
      setDriveStatus(`Client-side error checking file: ${error.message}`);
    }
  };

  const handleSaveToDrive = async () => { // Corrected function definition
    setDriveStatus('Saving...');
    const dummyData = { vehicles: [{id: 1, name: 'My Car'}], timestamp: new Date().toISOString() }; // Example data
    try {
      const response = await fetch('/api/drive/file-ops', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(dummyData),
      });
      const result = await response.json();
      if (response.ok) {
        setDriveStatus(`Data saved successfully! File ID: ${result.fileId}`);
        await handleCheckDriveFile(); // Refresh data
      } else {
        setDriveStatus(`Error saving data: ${result.error || response.statusText}`);
      }
    } catch (error) {
      setDriveStatus(`Client-side error saving data: ${error.message}`);
    }
  };

  if (status === 'loading') {
    return <p>Loading session...</p>;
  }

  return (
    <div>
      <h1>Profile Page</h1>
      {session ? (
        <div>
          <p>Signed in as: <strong>{session.user.name}</strong> ({session.user.email})</p>
          {session.user.image && <img src={session.user.image} alt='User avatar' style={{width: '50px', height: '50px', borderRadius: '50%'}} />}
          <button onClick={() => signOut()} style={{ padding: '10px', margin: '10px 0', backgroundColor: '#ff4d4d', color: 'white', border: 'none', borderRadius: '5px', cursor: 'pointer' }}>
            Sign out
          </button>

          <div style={{marginTop: '20px', borderTop: '1px solid #ccc', paddingTop: '20px'}}>
            <h2>Data Backup (Google Drive)</h2>
            {/* The 'Connect to Cloud' wording from HTML might be confusing now that sign-in implies connection.
                Perhaps change to 'Sync Status' or similar.
            */}
            <button onClick={handleCheckDriveFile} style={{ padding: '10px', margin: '5px', backgroundColor: '#e7edf4', color: '#0d151c', border: 'none', borderRadius: '20px', cursor: 'pointer' }}>
              Check/Load Data from Drive
            </button>
            <button onClick={handleSaveToDrive} style={{ padding: '10px', margin: '5px', backgroundColor: '#4CAF50', color: 'white', border: 'none', borderRadius: '20px', cursor: 'pointer' }}>
              Save Dummy Data to Drive
            </button>
            {driveStatus && <p>Status: {driveStatus}</p>}
            {driveData && <pre style={{backgroundColor: '#f0f0f0', padding: '10px', whiteSpace: 'pre-wrap', wordBreak: 'break-all'}}>Data: {JSON.stringify(driveData, null, 2)}</pre>}
          </div>

        </div>
      ) : (
        <div>
          <p>You are not signed in.</p>
          <button onClick={() => signIn('google')} style={{ padding: '10px', marginTop: '10px', backgroundColor: '#4285F4', color: 'white', border: 'none', borderRadius: '5px', cursor: 'pointer' }}>
            Sign in with Google
          </button>
          <p style={{marginTop: '10px', fontSize: '0.9em', color: 'gray'}}>Signing in will also request permission to access Google Drive for app data backup.</p>
        </div>
      )}
    </div>
  );
}
