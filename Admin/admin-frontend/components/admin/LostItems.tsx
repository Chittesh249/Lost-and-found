"use client";

import axios from "axios";
import React, { useEffect, useState } from "react";

type ClaimedBy = {
  email: string;
  user_id: string;
};

type LostItem = {
  item_id: string;
  item_name: string;
  description: string;
  location_lost: string;
  date_lost: string;
  reported_by_name: string;
  reported_by_roll: string | null;
  created_post: string;
  image_url: string;
  claimed_by: ClaimedBy | null;
};

const LostItems: React.FC = () => {
  const [lostItems, setLostItems] = useState<LostItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchLostItems = async () => {
      try {
        const response = await axios.get("/api/admin/items/list", {
          withCredentials: true,
        });

        setLostItems(response.data);
      } catch (error) {
        console.error("Failed to fetch lost items", error);
      } finally {
        setLoading(false);
      }
    };

    fetchLostItems();
  }, []);

  if (loading) return <div>Loading...</div>;

  return (
    <div className="flex flex-col gap-8">
      <div>
        <h2 className="font-semibold mb-4 text-xl">Pending Items</h2>
        <div className="flex flex-wrap gap-4">
          {lostItems
            .filter((item) => !item.claimed_by)
            .map((item) => (
              <div key={item.item_id} className="border rounded-lg p-4 min-w-[220px] shadow-sm bg-white">
                <img src={item.image_url} alt={item.item_name} className="w-full h-40 object-cover rounded-md mb-2" />
                <p><b>Item:</b> {item.item_name}</p>
                <p><b>Description:</b> {item.description}</p>
                <p><b>Location:</b> {item.location_lost}</p>
                <p><b>Date:</b> {item.date_lost}</p>
                <p><b>Reported By:</b> {item.reported_by_name}</p>
              </div>
            ))}
          {lostItems.filter((item) => !item.claimed_by).length === 0 && <p className="text-gray-500">No pending items.</p>}
        </div>
      </div>

      <div>
        <h2 className="font-semibold mb-4 text-xl">Claimed Items</h2>
        <div className="flex flex-wrap gap-4">
          {lostItems
            .filter((item) => item.claimed_by)
            .map((item) => (
              <div key={item.item_id} className="border rounded-lg p-4 min-w-[220px] shadow-sm bg-gray-50 opacity-80">
                <img src={item.image_url} alt={item.item_name} className="w-full h-40 object-cover rounded-md mb-2 grayscale" />
                <p><b>Item:</b> {item.item_name}</p>
                <p><b>Claimed By:</b> {item.claimed_by?.email}</p>
                <p className="text-xs text-green-600 font-bold mt-2">RESOLVED</p>
              </div>
            ))}
          {lostItems.filter((item) => item.claimed_by).length === 0 && <p className="text-gray-500">No claimed items yet.</p>}
        </div>
      </div>
    </div>
  );
};

export default LostItems;
