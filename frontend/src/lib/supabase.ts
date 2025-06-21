import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://bervahrnaauhznctodie.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJlcnZhaHJuYWF1aHpuY3RvZGllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0Njk0ODcsImV4cCI6MjA2NjA0NTQ4N30.JNKGYHAlpMCNOb6f3MBBpc8H2JQRR8vHbcsekme4GSc'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Database types
export interface User {
  id: string
  username: string
  email: string
  created_at: string
  last_login?: string
  is_verified: boolean
}

export interface Wallet {
  id: string
  user_id: string
  name: string
  public_key: string
  wallet_type: string
  sol_balance: number
  is_active: boolean
  created_at: string
  last_balance_update?: string
}

export interface Trade {
  id: string
  user_id: string
  wallet_id: string
  token_address: string
  token_symbol?: string
  trade_type: string
  sol_amount: number
  token_amount?: number
  price_per_token?: number
  status: string
  created_at: string
  executed_at?: string
  confirmed_at?: string
}

export interface BotConfig {
  id: string
  user_id: string
  bot_type: string
  name: string
  is_active: boolean
  config_json: any
  created_at: string
  updated_at: string
  last_run?: string
}