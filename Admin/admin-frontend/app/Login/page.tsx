// app/admin/login/page.tsx (Next.js 13+ with App Router)

"use client";

import { useState } from "react";
import axios from "axios";
import { useRouter } from "next/navigation";

export default function AdminLogin() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const response = await axios.post(
        'https://lost-and-found-es98.onrender.com/api/admin/login',
        { email, password }
      );

      if (response.status === 200) {
        router.push("/dashboard");
        return;
      }

      alert("Login failed. Please check your credentials.");
    } catch (error: unknown) {
      if (axios.isAxiosError(error)) {
        const status = error.response?.status;
        const message = (error.response?.data as { error?: string })?.error;
        if (status === 401) {
          alert(message || "Invalid email or password");
        } else {
          alert(message || "Unable to login right now. Please try again.");
        }
      } else {
        alert("Unexpected error occurred. Please try again.");
      }
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-100 to-indigo-100 w-full h-full">
      <div className="bg-white shadow-lg rounded-2xl w-full max-w-md p-8">
        <div className="flex flex-col items-center">
          <div className="bg-gradient-to-r  from-[#da0952] to-[#e3447c]  p-4 rounded-full">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className="h-10 w-10 text-white"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 11c0-1.104-.896-2-2-2s-2 .896-2 2 .896 2 2 2 2-.896 2-2zM4 6a2 2 0 012-2h12a2 2 0 012 2v12a2 2 0 01-2 2H6a2 2 0 01-2-2V6z"
              />
            </svg>
          </div>
          <h2 className="mt-4 text-2xl text-black font-bold">Admin Login</h2>
          <p className="text-gray-500 text-sm">
            Sign in to access the admin dashboard
          </p>
        </div>

        <form className="mt-6 space-y-5" onSubmit={handleSubmit}>
          <div>
            <label className="text-sm font-medium text-gray-700">
              Email Address
            </label>
            <input
              type="email"
              placeholder="admin@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="mt-2 w-full px-4 py-2 border text-black border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              required
            />
          </div>

          <div>
            <label className="text-sm font-medium text-gray-700">
              Password
            </label>
            <div className="relative mt-2">
              <input
                type="password"
                placeholder="Enter your password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-4 py-2 border text-black border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                required
              />
            </div>
          </div>

          <button
            type="submit"
            className="w-full py-2 px-4 bg-gradient-to-r from-[#da0952] to-[#e3447c] text-white rounded-lg hover:opacity-90 transition"
          >
            Sign In
          </button>
        </form>
      </div>
    </div>
  );
}
