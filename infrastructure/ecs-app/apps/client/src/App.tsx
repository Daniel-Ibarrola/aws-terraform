// src/App.tsx
import './App.css';
import PetList from './components/PetList';

function App() {
    return (
        <div className="App">
            <header>
                <h1>Pet Management App</h1>
            </header>
            <main>
                <PetList />
            </main>
        </div>
    );
}

export default App;