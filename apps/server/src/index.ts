import express, { Express, Request, Response } from 'express';
import cors from 'cors';


const app: Express = express();
const port = process.env.PORT || 3000;

app.use(cors());


// Define a Pet interface
interface Pet {
    id: number;
    name: string;
    type: string;
    breed: string;
    age: number;
    owner: string;
}

// Hardcoded list of pets for testing
const pets: Pet[] = [
    {
        id: 1,
        name: 'Max',
        type: 'Dog',
        breed: 'Golden Retriever',
        age: 3,
        owner: 'John Doe'
    },
    {
        id: 2,
        name: 'Bella',
        type: 'Cat',
        breed: 'Siamese',
        age: 2,
        owner: 'Jane Smith'
    },
    {
        id: 3,
        name: 'Buddy',
        type: 'Dog',
        breed: 'Labrador',
        age: 5,
        owner: 'Mike Johnson'
    },
    {
        id: 4,
        name: 'Charlie',
        type: 'Bird',
        breed: 'Parrot',
        age: 1,
        owner: 'Sarah Williams'
    },
    {
        id: 5,
        name: 'Lucy',
        type: 'Cat',
        breed: 'Persian',
        age: 4,
        owner: 'David Brown'
    }
];

// Root endpoint
app.get('/', (req: Request, res: Response) => {
    res.send('Express + TypeScript Server is running');
});

// New endpoint to get all pets
app.get('/api/pets', (req: Request, res: Response) => {
    res.json(pets);
});

app.listen(port, () => {
    console.log(`⚡️[server]: Server is running at http://localhost:${port}`);
});