import { useState, useEffect } from 'react';
import axios from 'axios';
import type {Pet} from '../types';
import {API_URL} from "../constants.ts";

const PetList = () => {
    const [pets, setPets] = useState<Pet[]>([]);
    const [loading, setLoading] = useState<boolean>(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchPets = async () => {
            try {
                setLoading(true);
                const response = await axios.get<Pet[]>(API_URL);
                setPets(response.data);
                setError(null);
            } catch (err) {
                setError('Failed to fetch pets. Is the server running?');
                console.error(err);
            } finally {
                setLoading(false);
            }
        };

        fetchPets();
    }, []);

    if (loading) return <div>Loading pets...</div>;
    if (error) return <div className="error">{error}</div>;

    return (
        <div className="pet-list">
            <h2>Pet List</h2>
            {pets.length === 0 ? (
                <p>No pets found.</p>
            ) : (
                <table>
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Type</th>
                        <th>Breed</th>
                        <th>Age</th>
                        <th>Owner</th>
                    </tr>
                    </thead>
                    <tbody>
                    {pets.map((pet) => (
                        <tr key={pet.id}>
                            <td>{pet.id}</td>
                            <td>{pet.name}</td>
                            <td>{pet.type}</td>
                            <td>{pet.breed}</td>
                            <td>{pet.age}</td>
                            <td>{pet.owner}</td>
                        </tr>
                    ))}
                    </tbody>
                </table>
            )}
        </div>
    );
};

export default PetList;