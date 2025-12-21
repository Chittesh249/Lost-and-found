"use client";
import React, { useEffect, useState } from 'react';
import axios from 'axios';

type User = {
    email: string;
    id?: string;
};

const UserCards: React.FC = () => {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchUsers = async () => {
            try {
                // Fetch from the secure Admin API
                const response = await axios.get('/api/admin/users', {
                    withCredentials: true // Ensure cookies (session) are sent if needed
                });
                setUsers(response.data);
            } catch (error) {
                console.error("Failed to fetch users", error);
            } finally {
                setLoading(false);
            }
        };
        fetchUsers();
    }, []);

    if (loading) return <div>Loading...</div>;

    return (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {users.map((user, index) => (
                <div
                    key={user.id || index}
                    className="p-4 border rounded-lg shadow-sm bg-white"
                >
                    <p className="font-medium text-gray-900">Email: {user.email}</p>
                    {user.id && <p className="text-xs text-gray-500">ID: {user.id}</p>}
                </div>
            ))}
            {users.length === 0 && <p>No users found.</p>}
        </div>
    );
};

export default UserCards;