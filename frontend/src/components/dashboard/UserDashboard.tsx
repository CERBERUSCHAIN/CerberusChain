import React, { useState, useEffect } from 'react'
import { supabase, User, Wallet, Trade, BotConfig } from '../../lib/supabase'
import './UserDashboard.css'

interface UserDashboardProps {
  user: any
  onLogout: () => void
}

export const UserDashboard: React.FC<UserDashboardProps> = ({ user, onLogout }) => {
  const [userData, setUserData] = useState<User | null>(null)
  const [wallets, setWallets] = useState<Wallet[]>([])
  const [trades, setTrades] = useState<Trade[]>([])
  const [botConfigs, setBotConfigs] = useState<BotConfig[]>([])
  const [loading, setLoading] = useState(true)
  const [activeTab, setActiveTab] = useState('overview')

  useEffect(() => {
    loadUserData()
  }, [user])

  const loadUserData = async () => {
    try {
      // Load user data
      const { data: userInfo } = await supabase
        .from('users')
        .select('*')
        .eq('id', user.id)
        .single()

      if (userInfo) {
        setUserData(userInfo)
      }

      // Load wallets
      const { data: walletsData } = await supabase
        .from('wallets')
        .select('*')
        .eq('user_id', user.id)
        .eq('is_active', true)

      if (walletsData) {
        setWallets(walletsData)
      }

      // Load recent trades
      const { data: tradesData } = await supabase
        .from('trades')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(10)

      if (tradesData) {
        setTrades(tradesData)
      }

      // Load bot configs
      const { data: botsData } = await supabase
        .from('bot_configs')
        .select('*')
        .eq('user_id', user.id)

      if (botsData) {
        setBotConfigs(botsData)
      }

    } catch (error) {
      console.error('Error loading user data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleLogout = async () => {
    await supabase.auth.signOut()
    onLogout()
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const formatSOL = (amount: number) => {
    return `${amount.toFixed(4)} SOL`
  }

  if (loading) {
    return (
      <div className="dashboard-loading">
        <div className="loading-spinner">
          <div className="spinner"></div>
          <p>Loading your dashboard...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="user-dashboard">
      {/* Header */}
      <header className="dashboard-header">
        <div className="header-content">
          <div className="user-info">
            <div className="user-avatar">
              {userData?.username?.charAt(0).toUpperCase() || 'U'}
            </div>
            <div className="user-details">
              <h1>Welcome back, {userData?.username || 'User'}</h1>
              <p>Member since {userData?.created_at ? formatDate(userData.created_at) : 'Unknown'}</p>
            </div>
          </div>
          <button onClick={handleLogout} className="logout-button">
            <span>🚪</span>
            Logout
          </button>
        </div>
      </header>

      {/* Navigation Tabs */}
      <nav className="dashboard-nav">
        <button
          className={`nav-tab ${activeTab === 'overview' ? 'active' : ''}`}
          onClick={() => setActiveTab('overview')}
        >
          📊 Overview
        </button>
        <button
          className={`nav-tab ${activeTab === 'wallets' ? 'active' : ''}`}
          onClick={() => setActiveTab('wallets')}
        >
          💰 Wallets
        </button>
        <button
          className={`nav-tab ${activeTab === 'trades' ? 'active' : ''}`}
          onClick={() => setActiveTab('trades')}
        >
          📈 Trades
        </button>
        <button
          className={`nav-tab ${activeTab === 'bots' ? 'active' : ''}`}
          onClick={() => setActiveTab('bots')}
        >
          🤖 Bots
        </button>
      </nav>

      {/* Content */}
      <main className="dashboard-content">
        {activeTab === 'overview' && (
          <div className="overview-tab">
            <div className="stats-grid">
              <div className="stat-card">
                <div className="stat-icon">💰</div>
                <div className="stat-info">
                  <h3>Total Wallets</h3>
                  <p className="stat-value">{wallets.length}</p>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">📈</div>
                <div className="stat-info">
                  <h3>Total Trades</h3>
                  <p className="stat-value">{trades.length}</p>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">🤖</div>
                <div className="stat-info">
                  <h3>Active Bots</h3>
                  <p className="stat-value">{botConfigs.filter(bot => bot.is_active).length}</p>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">💎</div>
                <div className="stat-info">
                  <h3>Total Balance</h3>
                  <p className="stat-value">
                    {formatSOL(wallets.reduce((sum, wallet) => sum + wallet.sol_balance, 0))}
                  </p>
                </div>
              </div>
            </div>

            <div className="recent-activity">
              <h2>Recent Activity</h2>
              {trades.length > 0 ? (
                <div className="activity-list">
                  {trades.slice(0, 5).map(trade => (
                    <div key={trade.id} className="activity-item">
                      <div className="activity-icon">
                        {trade.trade_type === 'buy' ? '🟢' : '🔴'}
                      </div>
                      <div className="activity-details">
                        <p className="activity-title">
                          {trade.trade_type.toUpperCase()} {trade.token_symbol || 'Token'}
                        </p>
                        <p className="activity-subtitle">
                          {formatSOL(trade.sol_amount)} • {formatDate(trade.created_at)}
                        </p>
                      </div>
                      <div className={`activity-status status-${trade.status}`}>
                        {trade.status}
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="empty-state">
                  <p>No trading activity yet. Start by creating a wallet!</p>
                </div>
              )}
            </div>
          </div>
        )}

        {activeTab === 'wallets' && (
          <div className="wallets-tab">
            <div className="tab-header">
              <h2>Your Wallets</h2>
              <button className="create-button">
                <span>➕</span>
                Create Wallet
              </button>
            </div>
            {wallets.length > 0 ? (
              <div className="wallets-grid">
                {wallets.map(wallet => (
                  <div key={wallet.id} className="wallet-card">
                    <div className="wallet-header">
                      <h3>{wallet.name}</h3>
                      <span className={`wallet-type type-${wallet.wallet_type}`}>
                        {wallet.wallet_type}
                      </span>
                    </div>
                    <div className="wallet-details">
                      <p className="wallet-address">
                        {wallet.public_key.slice(0, 8)}...{wallet.public_key.slice(-8)}
                      </p>
                      <p className="wallet-balance">
                        {formatSOL(wallet.sol_balance)}
                      </p>
                    </div>
                    <div className="wallet-actions">
                      <button className="wallet-action">View</button>
                      <button className="wallet-action">Send</button>
                      <button className="wallet-action">Receive</button>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="empty-state">
                <div className="empty-icon">💰</div>
                <h3>No Wallets Yet</h3>
                <p>Create your first Solana wallet to start trading</p>
                <button className="create-button primary">
                  Create Your First Wallet
                </button>
              </div>
            )}
          </div>
        )}

        {activeTab === 'trades' && (
          <div className="trades-tab">
            <div className="tab-header">
              <h2>Trading History</h2>
              <button className="create-button">
                <span>📈</span>
                New Trade
              </button>
            </div>
            {trades.length > 0 ? (
              <div className="trades-table">
                <div className="table-header">
                  <div>Type</div>
                  <div>Token</div>
                  <div>Amount</div>
                  <div>Status</div>
                  <div>Date</div>
                </div>
                {trades.map(trade => (
                  <div key={trade.id} className="table-row">
                    <div className={`trade-type type-${trade.trade_type}`}>
                      {trade.trade_type.toUpperCase()}
                    </div>
                    <div>{trade.token_symbol || 'Unknown'}</div>
                    <div>{formatSOL(trade.sol_amount)}</div>
                    <div className={`trade-status status-${trade.status}`}>
                      {trade.status}
                    </div>
                    <div>{formatDate(trade.created_at)}</div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="empty-state">
                <div className="empty-icon">📈</div>
                <h3>No Trades Yet</h3>
                <p>Start trading to see your transaction history</p>
                <button className="create-button primary">
                  Make Your First Trade
                </button>
              </div>
            )}
          </div>
        )}

        {activeTab === 'bots' && (
          <div className="bots-tab">
            <div className="tab-header">
              <h2>Trading Bots</h2>
              <button className="create-button">
                <span>🤖</span>
                Create Bot
              </button>
            </div>
            {botConfigs.length > 0 ? (
              <div className="bots-grid">
                {botConfigs.map(bot => (
                  <div key={bot.id} className="bot-card">
                    <div className="bot-header">
                      <h3>{bot.name}</h3>
                      <div className={`bot-status ${bot.is_active ? 'active' : 'inactive'}`}>
                        {bot.is_active ? '🟢 Active' : '🔴 Inactive'}
                      </div>
                    </div>
                    <div className="bot-details">
                      <p className="bot-type">Type: {bot.bot_type}</p>
                      <p className="bot-updated">
                        Updated: {formatDate(bot.updated_at)}
                      </p>
                      {bot.last_run && (
                        <p className="bot-last-run">
                          Last run: {formatDate(bot.last_run)}
                        </p>
                      )}
                    </div>
                    <div className="bot-actions">
                      <button className="bot-action">Configure</button>
                      <button className={`bot-action ${bot.is_active ? 'stop' : 'start'}`}>
                        {bot.is_active ? 'Stop' : 'Start'}
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="empty-state">
                <div className="empty-icon">🤖</div>
                <h3>No Bots Configured</h3>
                <p>Create your first trading bot to automate your strategy</p>
                <button className="create-button primary">
                  Create Your First Bot
                </button>
              </div>
            )}
          </div>
        )}
      </main>
    </div>
  )
}