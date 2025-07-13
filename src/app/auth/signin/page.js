'use client';

import { useState } from 'react';

export default function SignInPage() {
  const [formData, setFormData] = useState({ email: '', password: '' });

  const handleChange = (e) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Signing up with:', formData);
    // Add signup API call here
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <form onSubmit={handleSubmit} className="bg-white p-8 rounded shadow-md w-full max-w-md">
        <h2 className="text-2xl font-bold mb-6 text-center">Create your CloudBro account</h2>

        <div className="mb-4">
          <label className="block font-medium mb-1" htmlFor="email">Email</label>
          <input
            className="w-full px-3 py-2 border rounded"
            id="email"
            name="email"
            type="email"
            required
            value={formData.email}
            onChange={handleChange}
          />
        </div>

        <div className="mb-4">
          <label className="block font-medium mb-1" htmlFor="password">Password</label>
          <input
            className="w-full px-3 py-2 border rounded"
            id="password"
            name="password"
            type="password"
            required
            value={formData.password}
            onChange={handleChange}
          />
        </div>

        <button
          type="submit"
          className="w-full bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700"
        >
          Sign Up
        </button>

        <p className="text-center mt-4 text-sm">
          Already have an account? <a href="/auth/login" className="text-blue-600">Login</a>
        </p>
      </form>
    </div>
  );
}
