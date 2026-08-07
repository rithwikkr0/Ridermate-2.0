import React, { useEffect, useState } from 'react';
import { Save, User, LogOut } from 'lucide-react';
import { getProfile, saveProfile, logoutUser } from '../services/storageService';
import { UserProfile } from '../types';
import { useNavigate } from 'react-router-dom';

export const Profile: React.FC = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState<UserProfile>({
    name: '',
    age: 0,
    city: '',
    vehicleType: '',
    weight: 0
  });

  useEffect(() => {
    setFormData(getProfile());
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSave = () => {
    saveProfile(formData);
    navigate('/');
  };

  const handleLogout = () => {
    logoutUser();
    navigate('/login');
  };

  return (
    <div className="p-4 bg-gray-950 min-h-screen pb-20">
      <div className="flex items-center mb-8">
         <button onClick={() => navigate('/')} className="text-gray-400 mr-4">Cancel</button>
         <h1 className="text-xl font-bold text-white">Edit Profile</h1>
      </div>

      <div className="space-y-6">
        <div className="flex justify-center mb-6">
           <div className="w-24 h-24 rounded-full bg-gray-800 border-2 border-brand-teal flex items-center justify-center">
              <User size={40} className="text-brand-teal" />
           </div>
        </div>

        <div className="space-y-2">
           <label className="text-gray-400 text-sm">Full Name</label>
           <input 
             name="name"
             value={formData.name}
             onChange={handleChange}
             className="w-full bg-brand-card border border-gray-700 rounded-lg p-3 text-white focus:border-brand-teal focus:outline-none"
           />
        </div>

        <div className="space-y-2">
           <label className="text-gray-400 text-sm">City</label>
           <input 
             name="city"
             value={formData.city}
             onChange={handleChange}
             className="w-full bg-brand-card border border-gray-700 rounded-lg p-3 text-white focus:border-brand-teal focus:outline-none"
           />
        </div>

        <div className="space-y-2">
           <label className="text-gray-400 text-sm">Vehicle Type</label>
           <select 
             name="vehicleType"
             value={formData.vehicleType}
             onChange={handleChange}
             className="w-full bg-brand-card border border-gray-700 rounded-lg p-3 text-white focus:border-brand-teal focus:outline-none"
           >
             <option value="Motorcycle">Motorcycle</option>
             <option value="Scooter">Scooter</option>
             <option value="Electric Bike">Electric Bike</option>
           </select>
        </div>

        <div className="grid grid-cols-2 gap-4">
           <div className="space-y-2">
             <label className="text-gray-400 text-sm">Age</label>
             <input 
               name="age"
               type="number"
               value={formData.age}
               onChange={handleChange}
               className="w-full bg-brand-card border border-gray-700 rounded-lg p-3 text-white focus:border-brand-teal focus:outline-none"
             />
           </div>
           <div className="space-y-2">
             <label className="text-gray-400 text-sm">Weight (kg)</label>
             <input 
               name="weight"
               type="number"
               value={formData.weight}
               onChange={handleChange}
               className="w-full bg-brand-card border border-gray-700 rounded-lg p-3 text-white focus:border-brand-teal focus:outline-none"
             />
           </div>
        </div>

        <button 
          onClick={handleSave}
          className="w-full bg-brand-teal text-black font-bold py-4 rounded-xl mt-8 flex items-center justify-center space-x-2 shadow-lg shadow-brand-teal/20"
        >
          <Save size={20} />
          <span>Save Profile</span>
        </button>

        <button 
          onClick={handleLogout}
          className="w-full bg-gray-800 text-red-400 font-bold py-4 rounded-xl mt-4 flex items-center justify-center space-x-2 border border-gray-700 hover:bg-gray-700"
        >
          <LogOut size={20} />
          <span>Logout</span>
        </button>
      </div>
    </div>
  );
};