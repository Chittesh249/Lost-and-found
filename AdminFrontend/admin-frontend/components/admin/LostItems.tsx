"use client";
import React, { useEffect, useState } from 'react';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

type LostItems = {
    item_id: string;
    item_name: string;
    description: string;
    location_lost: string;
    date_lost: string;
    reported_by_name: string;
    reported_by_roll: string;
    created_post: string;
    image_url: string;
    claimed_by:string | null;
};

const LostItems: React.FC = () => {
    const [lostItems, setLostItems] = useState<LostItems[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchLostItems = async () => {
            const { data, error } = await supabase
                .from('Lost_items')
                .select('item_id, item_name, description, location_lost, date_lost, reported_by_name, reported_by_roll, created_post, image_url,claimed_by');
            if (!error && data) {
                setLostItems(data);
                console.log(data);
            }
            setLoading(false);
        };
        fetchLostItems();
    }, []);

    if (loading) return <div>Loading...</div>;

    return (
        <>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '16px' }}>
            {lostItems.map(item => (
                item.claimed_by === null &&
                <div
                    key={item.item_id}
                    style={{
                        border: '1px solid #ccc',
                        borderRadius: '8px',
                        padding: '16px',
                        minWidth: '220px',
                        boxShadow: '0 2px 8px rgba(0,0,0,0.05)',
                    }}
                >
                    <img src={item.image_url} alt={item.item_name} className='object-cover w-32 flex items-center justify-center'  />
                    <p className='text-md font-bold'>Item Name: {item.item_name}</p>
                    <p className='text-md font-bold'>Description: {item.description}</p>
                    <p className='text-md font-bold'>Location Lost: {item.location_lost}</p>
                    <p className='text-md font-bold'>Date Lost: {item.date_lost}</p>
                    <p className='text-md font-bold'>Reported By: {item.reported_by_name} ({item.reported_by_roll ? item.reported_by_roll : 'Unknown'})</p>
                    <p className='text-md font-bold'>Created Post: {item.created_post}</p>
                    <p className='text-md font-bold'>Claimed By: {item.claimed_by ? item.claimed_by['email'] : 'Unknown'}</p>
                </div>
            ))}
        </div>
        <div className='font-semibold mt-8 mb-4 flex flex-wrap'>
            <div className='w-full border-1 flex items-center justify-center h-20 border-zinc-900 p-2 rounded-xl mb-6 bg-gray-300'>Claimed Items</div>
            {lostItems.map(item => (
                item.claimed_by != null &&
                <div
                    key={item.item_id}
                    style={{
                        border: '1px solid #ccc',
                        borderRadius: '8px',
                        padding: '16px',
                        minWidth: '220px',
                        boxShadow: '0 2px 8px rgba(0,0,0,0.05)',
                        width: '500px',
                    }}
                >
                    <img src={item.image_url} alt={item.item_name} className='object-cover w-32 flex items-center justify-center'  />
                    <p className='text-md font-bold'>Item Name: {item.item_name}</p>
                    <p className='text-md font-bold'>Description: {item.description}</p>
                    <p className='text-md font-bold'>Location Lost: {item.location_lost}</p>
                    <p className='text-md font-bold'>Date Lost: {item.date_lost}</p>
                    <p className='text-md font-bold'>Reported By: {item.reported_by_name} ({item.reported_by_roll ? item.reported_by_roll : 'Unknown'})</p>
                    <p className='text-md font-bold'>Created Post: {item.created_post}</p>
                    <p className='text-md font-bold'>Claimed By: {item.claimed_by ? item.claimed_by['email'] : 'Unknown'}</p>
                </div>
            ))}
        </div>
        </>
    );
};

export default LostItems;