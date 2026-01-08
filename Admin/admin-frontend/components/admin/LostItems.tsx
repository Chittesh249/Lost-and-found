"use client";

import axios from "axios";
import React, { useEffect, useState } from "react";

type LostItem = {
  post_id: number;
  post_type: string;
  item_name: string;
  description: string;
  image_url: string | null;
  status: string; // 'OPEN' or 'CLAIMED'
  created_at: string;
  security_question: string | null;
  security_answer: string | null;
  resolved_by: string | null; // This seems to be a text field based on schema, maybe user email/name?
  user_id: string | null;
  latitude: number | null;
  longitude: number | null;
  reward: string | null;
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
            .filter((item) => item.status === 'OPEN') // Assuming 'OPEN' is the status for pending
            .map((item) => (
              <div key={item.post_id} className="dark:bg-zinc-800 bg-white border rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow flex flex-col h-full">
                <div className="relative aspect-[4/3] w-full bg-gray-100">
                  {item.image_url ? (
                    <img src={item.image_url} alt={item.item_name} className="w-full h-full object-cover" />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-gray-400">No Image</div>
                  )}
                </div>
                <div className="p-4 flex flex-col gap-2 flex-grow">
                  <h3 className="font-bold text-lg truncate" title={item.item_name}>{item.item_name}</h3>
                  <p className="text-sm text-muted-foreground line-clamp-2 flex-grow">{item.description}</p>
                  <div className="mt-2 text-sm space-y-1">
                    {/* Location is lat/long now, maybe just show if available? or generic text */}
                    {(item.latitude && item.longitude) && <p><span className="font-semibold">Loc:</span> {item.latitude.toFixed(4)}, {item.longitude.toFixed(4)}</p>}
                    <p><span className="font-semibold">Date:</span> {new Date(item.created_at).toLocaleDateString()}</p>
                    {item.reward && <p><span className="font-semibold text-green-600">Reward:</span> {item.reward}</p>}
                  </div>
                  <div className="mt-auto pt-3 border-t text-xs text-muted-foreground">
                    Items ID: {item.post_id}
                  </div>
                </div>
              </div>
            ))}
          {lostItems.filter((item) => item.status === 'OPEN').length === 0 && <p className="col-span-full text-center py-10 text-muted-foreground">No pending items.</p>}
        </div>
      </div>

      <div>
        <h2 className="font-semibold mb-4 text-2xl border-b pb-2">Claimed Items</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {lostItems
            .filter((item) => item.status === 'CLAIMED') // Assuming 'CLAIMED' is the status
            .map((item) => (
              <div key={item.post_id} className="dark:bg-zinc-800/50 bg-gray-50 border rounded-xl overflow-hidden opacity-75 hover:opacity-100 transition-opacity flex flex-col h-full">
                <div className="relative aspect-[4/3] w-full bg-gray-200">
                  {item.image_url ? (
                    <img src={item.image_url} alt={item.item_name} className="w-full h-full object-cover grayscale" />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-gray-400 bg-gray-300">No Image</div>
                  )}
                  <div className="absolute inset-0 flex items-center justify-center bg-black/20">
                    <span className="bg-green-600 text-white text-xs font-bold px-3 py-1 rounded-full uppercase tracking-wider shadow-sm">Resolved</span>
                  </div>
                </div>

                <div className="p-4 flex flex-col gap-2 flex-grow">
                  <h3 className="font-bold text-lg truncate text-muted-foreground">{item.item_name}</h3>
                  <div className="mt-auto text-sm">
                    <p className="font-medium text-green-700 dark:text-green-400">Claimed by:</p>
                    {/* resolved_by is a text field in schema, likely empty if not claimed via this specific flow, or contains claimer info */}
                    <p className="truncate" title={item.resolved_by || 'Unknown'}>{item.resolved_by || 'Unknown'}</p>
                  </div>
                </div>
              </div>
            ))}
          {lostItems.filter((item) => item.status === 'CLAIMED').length === 0 && <p className="col-span-full text-center py-10 text-muted-foreground">No claimed items yet.</p>}
        </div>
      </div>
    </div>
  );
};

export default LostItems;
