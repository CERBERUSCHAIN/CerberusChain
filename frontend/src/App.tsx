import React, { useState, useEffect } from 'react'
import { supabase } from './lib/supabase'
import { useAuth } from './hooks/useAuth'
import { AuthModal } from './components/auth/AuthModal'
import { UserDashboard } from './components/dashboard/UserDashboard'
import './App.css'

interface HealthStatus {
  status: string;
  service: string;
  version: string;
  timestamp: string;
  database?: {
    connected: boolean;
    stats?: any;
  };
}

interface SupabaseStatus {
  connected: boolean;
  tablesCount: number;
  error?: string;
}

function App() {
  const { user, loading: authLoading, signOut } = useAuth()
  const [backendStatus, setBackendStatus] = useState<HealthStatus | null>(null);
  const [supabaseStatus, setSupabaseStatus] = useState<SupabaseStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [authModalOpen, setAuthModalOpen] = useState(false);
  const [authMode, setAuthMode] = useState<'login' | 'register'>('login');

  useEffect(() => {
    // Check backend connection
    fetch('http://localhost:8080/')
      .then(res => res.json())
      .then((data: HealthStatus) => {
        setBackendStatus(data);
      })
      .catch(err => {
        console.error('Backend connection failed:', err);
      });

    // Check Supabase connection
    checkSupabaseConnection();
    
    setLoading(false);
  }, []);

  const checkSupabaseConnection = async () => {
    try {
      // Test Supabase connection by checking if we can query the users table
      const { error } = await supabase
        .from('users')
        .select('count', { count: 'exact', head: true });

      if (error) {
        setSupabaseStatus({
          connected: false,
          tablesCount: 0,
          error: error.message
        });
      } else {
        // Get table count from information_schema
        const { data: tables } = await supabase
          .rpc('get_table_count');

        setSupabaseStatus({
          connected: true,
          tablesCount: tables || 7 // Default to expected table count
        });
      }
    } catch (err) {
      setSupabaseStatus({
        connected: false,
        tablesCount: 0,
        error: 'Connection failed'
      });
    }
  };

  const handleAuthSuccess = (user: any) => {
    setAuthModalOpen(false);
  };

  const handleLogout = async () => {
    await signOut();
  };

  const openAuthModal = (mode: 'login' | 'register') => {
    setAuthMode(mode);
    setAuthModalOpen(true);
  };

  // Show loading screen while checking auth
  if (authLoading) {
    return (
      <div className="App">
        <div className="auth-loading">
          <div className="loading-spinner">
            <div className="spinner"></div>
            <p>Loading Cerberus Chain...</p>
          </div>
        </div>
      </div>
    );
  }

  // Show dashboard if user is authenticated
  if (user) {
    return (
      <UserDashboard 
        user={user} 
        onLogout={handleLogout}
      />
    );
  }

  // Show main landing page with auth options
  return (
    <div className="App">
      <header className="App-header">
        <div className="logo">
          <h1>🐺 Cerberus Chain: Hydra</h1>
          <p className="tagline">The Three-Headed Guardian of Memecoin Trading</p>
        </div>

        <div className="auth-section">
          <h2>Access Your Trading Dashboard</h2>
          <p>Sign in to manage your wallets, trades, and trading bots</p>
          <div className="auth-buttons">
            <button 
              className="auth-cta-button primary"
              onClick={() => openAuthModal('login')}
            >
              Sign In
            </button>
            <button 
              className="auth-cta-button secondary"
              onClick={() => openAuthModal('register')}
            >
              Create Account
            </button>
          </div>
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

            <div className="status-card">
              <h3>🗄️ Supabase Database</h3>
              {loading ? (
                <div className="loading">Checking...</div>
              ) : supabaseStatus?.connected ? (
                <div className="status-healthy">
                  <div className="status-indicator healthy"></div>
                  <div>
                    <div>Status: Connected</div>
                    <div>Tables: {supabaseStatus.tablesCount}</div>
                    <div>Type: PostgreSQL</div>
                  </div>
                </div>
              ) : (
                <div className="status-error">
                  <div className="status-indicator error"></div>
                  <div>
                    <div>Connection Failed</div>
                    {supabaseStatus?.error && (
                      <div className="error-details">
                        {supabaseStatus.error}
                      </div>
                    )}
                  </div>
                </div>
              )}
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
              <strong>Supabase URL:</strong> https://bervahrnaauhznctodie.supabase.co
            </div>
            <div className="info-item">
              <strong>Status:</strong> Development Mode
            </div>
          </div>
        </div>

        <div className="supabase-section">
          <h2>🚀 Supabase Integration</h2>
          <div className="supabase-info">
            <div className="supabase-card">
              <h3>Database Schema</h3>
              <ul>
                <li>✅ Users table (authentication)</li>
                <li>✅ Wallets table (Solana wallets)</li>
                <li>✅ Trades table (transaction history)</li>
                <li>✅ Bot configs table (trading bots)</li>
                <li>✅ Sessions table (JWT management)</li>
              </ul>
            </div>
            <div className="supabase-card">
              <h3>Features Available</h3>
              <ul>
                <li>🔐 User authentication</li>
                <li>💰 Wallet management</li>
                <li>📊 Real-time data</li>
                <li>🤖 Bot configuration</li>
                <li>🔒 Row Level Security</li>
              </ul>
            </div>
          </div>
        </div>
      </header>

      <AuthModal
        isOpen={authModalOpen}
        onClose={() => setAuthModalOpen(false)}
        onSuccess={handleAuthSuccess}
        initialMode={authMode}
      />
    </div>
  )
}

export default App