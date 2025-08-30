"use client";
import { useState } from "react";
import { createClient } from "@supabase/supabase-js";
import axios from "axios";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL as string;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY as string;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

interface LostItem {
  name: string;
  dateLost: string;
  securityQuestion: string;
  answer: string;
}

export default function DashboardPage() {
  const [lostItem, setLostItem] = useState<LostItem>({
    name: "",
    dateLost: "",
    securityQuestion: "",
    answer: "",
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setLostItem({ ...lostItem, [name]: value });
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const data = await axios.post('http://localhost:3000/api/add_items', lostItem);
    if (data){
        console.log("Item added successfully:", data);
    }
    setLostItem({ name: "", dateLost: "", securityQuestion: "", answer: ""}); // Reset form
  };

  return (
    <div className="space-y-6 flex flex-col items-center">
        <h1 className="font-extrabold text-4xl">Enter the details of the newly lost item</h1>
      <section className="flex gap-4 lg:grid-cols-3 w-full ">
        <form onSubmit={handleSubmit} className="space-y-4 flex flex-col justify-center w-full">
          <div>
            <label htmlFor="name" className="block text-sm font-medium">Item Name</label>
            <input
              type="text"
              name="name"
              id="name"
              value={lostItem.name}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>
          <div>
            <label htmlFor="dateLost" className="block text-sm font-medium">Date Lost</label>
            <input
              type="date"
              name="dateLost"
              id="dateLost"
              value={lostItem.dateLost}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>
          <div>
            <label htmlFor="securityQuestion" className="block text-sm font-medium">Security Question</label>
            <select
              name="securityQuestion"
              id="securityQuestion"
              value={lostItem.securityQuestion}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            >
              <option value="">Select a question</option>
              <option value="What is your pet's name?">What is your pet's name?</option>
              <option value="What is your mother's maiden name?">What is your mother's maiden name?</option>
              <option value="What was the name of your first school?">What was the name of your first school?</option>
            </select>
          </div>
          <button type="submit" className="mt-4 bg-blue-500 text-white rounded-md p-2">Submit</button>
        </form>
      </section>
    </div>
  );
}