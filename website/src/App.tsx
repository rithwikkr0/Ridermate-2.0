import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Navbar } from './components/Navbar';
import { Footer } from './components/Footer';
import { HomePage } from './pages/HomePage';
import { DownloadPage } from './pages/DownloadPage';
import { JoinPage } from './pages/JoinPage';
import { PrivacyPage } from './pages/PrivacyPage';
import { DataSafetyPage } from './pages/DataSafetyPage';

export const App: React.FC = () => {
  return (
    <BrowserRouter>
      <div className="min-h-screen flex flex-col bg-background text-onSurface">
        {/* Navigation Bar */}
        <Navbar />

        {/* Main Routed Content */}
        <main className="flex-grow">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/download" element={<DownloadPage />} />
            <Route path="/join" element={<JoinPage />} />
            <Route path="/privacy" element={<PrivacyPage />} />
            <Route path="/data-safety" element={<DataSafetyPage />} />
            {/* Fallback */}
            <Route path="*" element={<HomePage />} />
          </Routes>
        </main>

        {/* Global Footer */}
        <Footer />
      </div>
    </BrowserRouter>
  );
};

export default App;
