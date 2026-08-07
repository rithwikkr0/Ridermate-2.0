import React from 'react';
import { HashRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Navigation } from './components/Navigation';
import { Home } from './pages/Home';
import { RideTracker } from './pages/RideTracker';
import { RideHistory } from './pages/RideHistory';
import { AICoach } from './pages/AICoach';
import { Profile } from './pages/Profile';
import { Memories } from './pages/Memories';
import { Social } from './pages/Social';
import { Login } from './pages/Login';
import { isAuthenticated } from './services/storageService';

// Fix: Use React.PropsWithChildren to ensure children is optional in the type definition, preventing strict TS errors.
const ProtectedRoute = ({ children }: React.PropsWithChildren) => {
  if (!isAuthenticated()) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
};

const App: React.FC = () => {
  return (
    <HashRouter>
      <div className="min-h-screen bg-gray-950 font-sans">
        <Routes>
          <Route path="/login" element={<Login />} />
          
          <Route path="/" element={<ProtectedRoute><Home /></ProtectedRoute>} />
          <Route path="/ride" element={<ProtectedRoute><RideTracker /></ProtectedRoute>} />
          <Route path="/history" element={<ProtectedRoute><RideHistory /></ProtectedRoute>} />
          <Route path="/coach" element={<ProtectedRoute><AICoach /></ProtectedRoute>} />
          <Route path="/profile" element={<ProtectedRoute><Profile /></ProtectedRoute>} />
          <Route path="/memories" element={<ProtectedRoute><Memories /></ProtectedRoute>} />
          <Route path="/social" element={<ProtectedRoute><Social /></ProtectedRoute>} />
          
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
        <Navigation />
      </div>
    </HashRouter>
  );
};

export default App;