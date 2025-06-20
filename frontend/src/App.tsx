import React, { useState, useEffect } from 'react'
import './App.css'

interface HealthStatus {
  status: string;
  service: string;
  version: string;
  timestamp: string;
}

function App() {
  const [backendStatus, setBackendStatus] = useState<HealthStatus | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check backend connection
    fetch('http://localhost:8080/')
      .then(res => res.json())
      .then((data: HealthStatus) => {
        setBackendStatus(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Backend connection failed:', err);
        setLoading(false);
      });
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <div className="logo">
          <h1>🐺 Cerberus Chain: Hydra</h1>
          <p className="tagline">The Three-Headed Guardian of Memecoin Trading</p>
        </div>
        
        <div className="status-section">
          <h2>System Status</h2>
          
          <div className="status-grid">
            <div className="status-card">
              <h3>🦀 Backend (Rust)</h3>
              {loading ? (
                <div className="loading">Checking...</div>
              ) : backendStatus ? (
                <div className="status-healthy">
                  <div className="status-indicator healthy"></div>
                  <div>
                    <div>Status: {backendStatus.status}</div>
                    <div>Version: {backendStatus.version}</div>
                    <div>Service: {backendStatus.service}</div>
                  </div>
                </div>
              ) : (
                <div className="status-error">
                  <div className="status-indicator error"></div>
                  <div>Connection Failed</div>
                </div>
              )}
            </div>

            <div className="status-card">
              <h3>⚛️ Frontend (React)</h3>
              <div className="status-healthy">
                <div className="status-indicator healthy"></div>
                <div>
                  <div>Status: Running</div>
                  <div>Port: 5173</div>
                  <div>Framework: React + Vite</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="features-section">
          <h2>The Three Heads of Cerberus</h2>
          <div className="features-grid">
            <div className="feature-card">
              <div className="feature-icon">📊</div>
              <h3>Strategy</h3>
              <p>Automated entry & exit rules tailored for memes</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">📈</div>
              <h3>Volume</h3>
              <p>Real-time detection of token volume spikes</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">🛡️</div>
              <h3>Security</h3>
              <p>On-chain rug-pull filters to protect funds</p>
            </div>
          </div>
        </div>

        <div className="info-section">
          <h2>Development Environment</h2>
          <div className="info-grid">
            <div className="info-item">
              <strong>Backend URL:</strong> http://localhost:8080
            </div>
            <div className="info-item">
              <strong>Frontend URL:</strong> http://localhost:5173
            </div>
            <div className="info-item">
              <strong>Status:</strong> Development Mode
            </div>
          </div>
        </div>
      </header>
    </div>
  )
}

export default App