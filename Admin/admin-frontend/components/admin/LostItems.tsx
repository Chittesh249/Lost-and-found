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
    <div className="flex flex-col gap-10">
      <div>
        <h2 className="font-semibold mb-4 text-2xl border-b pb-2">Pending Items</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {lostItems
            .filter((item) => !item.claimed_by)
            .map((item) => (
              <div key={item.item_id} className="dark:bg-zinc-800 bg-white border rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow flex flex-col h-full">
                <div className="relative aspect-[4/3] w-full bg-gray-100">
                  <img src={item.image_url} alt={item.item_name} className="w-full h-full object-cover" />
                </div>
                <div className="p-4 flex flex-col gap-2 flex-grow">
                  <h3 className="font-bold text-lg truncate" title={item.item_name}>{item.item_name}</h3>
                  <p className="text-sm text-muted-foreground line-clamp-2 flex-grow">{item.description}</p>
                  <div className="mt-2 text-sm space-y-1">
                    <p><span className="font-semibold">Loc:</span> {item.location_lost}</p>
                    <p><span className="font-semibold">Date:</span> {new Date(item.date_lost).toLocaleDateString()}</p>
                  </div>
                  <div className="mt-auto pt-3 border-t text-xs text-muted-foreground">
                    Reported by: {item.reported_by_name}
                  </div>
                </div>
              </div>
            ))}
          {lostItems.filter((item) => !item.claimed_by).length === 0 && <p className="col-span-full text-center py-10 text-muted-foreground">No pending items.</p>}
        </div>
      </div>

      <div>
        <h2 className="font-semibold mb-4 text-2xl border-b pb-2">Claimed Items</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {lostItems
            .filter((item) => item.claimed_by)
            .map((item) => (
              <div key={item.item_id} className="dark:bg-zinc-800/50 bg-gray-50 border rounded-xl overflow-hidden opacity-75 hover:opacity-100 transition-opacity flex flex-col h-full">
                <div className="relative aspect-[4/3] w-full bg-gray-200">
                  <img src={item.image_url} alt={item.item_name} className="w-full h-full object-cover grayscale" />
                  <div className="absolute inset-0 flex items-center justify-center bg-black/20">
                    <span className="bg-green-600 text-white text-xs font-bold px-3 py-1 rounded-full uppercase tracking-wider shadow-sm">Resolved</span>
                  </div>
                </div>

                <div className="p-4 flex flex-col gap-2 flex-grow">
                  <h3 className="font-bold text-lg truncate text-muted-foreground">{item.item_name}</h3>
                  <div className="mt-auto text-sm">
                    <p className="font-medium text-green-700 dark:text-green-400">Claimed by:</p>
                    <p className="truncate" title={item.claimed_by?.email}>{item.claimed_by?.email}</p>
                  </div>
                </div>
              </div>
            ))}
          {lostItems.filter((item) => item.claimed_by).length === 0 && <p className="col-span-full text-center py-10 text-muted-foreground">No claimed items yet.</p>}
        </div>
      </div>
    </div>
  );
};

export default LostItems;
