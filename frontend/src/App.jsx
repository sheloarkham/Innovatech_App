import { useState, useEffect } from 'react'
import axios from 'axios'
import './App.css'

// Variable de entorno para API URL
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000';

function App() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [health, setHealth] = useState(null);

  useEffect(() => {
    checkHealth();
    fetchUsers();
  }, []);

  const checkHealth = async () => {
    try {
      const response = await axios.get(`${API_URL}/health`);
      setHealth(response.data);
    } catch (err) {
      console.error('Error checking health:', err);
    }
  };

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/api/users`);
      setUsers(response.data);
      setError(null);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 Innovatech App</h1>
        <p>Frontend Contenerizado con Docker</p>
        
        {health && (
          <div className={`health-badge ${health.status}`}>
            Backend: {health.status} | DB: {health.database}
          </div>
        )}
      </header>

      <main>
        <section className="users-section">
          <h2>Usuarios</h2>
          {loading && <p>Cargando...</p>}
          {error && <p className="error">Error: {error}</p>}
          
          {!loading && !error && users.length === 0 && (
            <p>No hay usuarios registrados</p>
          )}

          {!loading && !error && users.length > 0 && (
            <ul className="users-list">
              {users.map(user => (
                <li key={user.id}>
                  <strong>{user.name}</strong> - {user.email}
                </li>
              ))}
            </ul>
          )}
        </section>

        <section className="info-section">
          <h3>📦 Características del Proyecto</h3>
          <ul>
            <li>✅ Frontend y Backend contenerizados</li>
            <li>✅ Dockerfiles con multi-stage build</li>
            <li>✅ docker-compose.yml funcional</li>
            <li>✅ Persistencia de datos con volúmenes</li>
            <li>✅ Variables de entorno configuradas</li>
          </ul>
        </section>
      </main>
    </div>
  )
}

export default App
