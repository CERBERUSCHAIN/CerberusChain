import React, { useState } from 'react'
import { supabase } from '../../lib/supabase'
import './AuthForms.css'

interface RegisterFormProps {
  onSuccess: (user: any) => void
  onSwitchToLogin: () => void
}

export const RegisterForm: React.FC<RegisterFormProps> = ({ onSuccess, onSwitchToLogin }) => {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: ''
  })
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [passwordStrength, setPasswordStrength] = useState(0)

  const validatePassword = (password: string) => {
    let strength = 0
    if (password.length >= 8) strength++
    if (/[A-Z]/.test(password)) strength++
    if (/[a-z]/.test(password)) strength++
    if (/[0-9]/.test(password)) strength++
    if (/[^A-Za-z0-9]/.test(password)) strength++
    return strength
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    // Validation
    if (formData.password !== formData.confirmPassword) {
      setError('Passwords do not match')
      setLoading(false)
      return
    }

    if (passwordStrength < 3) {
      setError('Password is too weak. Please use at least 8 characters with uppercase, lowercase, and numbers.')
      setLoading(false)
      return
    }

    try {
      // First, sign up with Supabase Auth
      const { data, error } = await supabase.auth.signUp({
        email: formData.email,
        password: formData.password,
        options: {
          data: {
            username: formData.username
          }
        }
      })

      if (error) {
        setError(error.message)
        return
      }

      if (data.user) {
        // Insert user data into our custom users table
        const { error: insertError } = await supabase
          .from('users')
          .insert([
            {
              id: data.user.id,
              username: formData.username,
              email: formData.email,
              password_hash: 'managed_by_supabase_auth', // Placeholder since Supabase handles this
              is_verified: false
            }
          ])

        if (insertError) {
          console.error('Error inserting user data:', insertError)
          // Continue anyway since auth user was created
        }

        onSuccess(data.user)
      }
    } catch (err) {
      setError('An unexpected error occurred')
    } finally {
      setLoading(false)
    }
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: value
    }))

    if (name === 'password') {
      setPasswordStrength(validatePassword(value))
    }
  }

  const getStrengthColor = () => {
    if (passwordStrength <= 1) return '#ff4444'
    if (passwordStrength <= 3) return '#ffaa00'
    return '#00ff88'
  }

  const getStrengthText = () => {
    if (passwordStrength <= 1) return 'Weak'
    if (passwordStrength <= 3) return 'Medium'
    return 'Strong'
  }

  return (
    <div className="auth-form">
      <div className="auth-header">
        <h2>Join Cerberus Chain</h2>
        <p>Create your account to start trading</p>
      </div>

      <form onSubmit={handleSubmit} className="auth-form-content">
        {error && (
          <div className="error-message">
            <span className="error-icon">⚠️</span>
            {error}
          </div>
        )}

        <div className="form-group">
          <label htmlFor="username">Username</label>
          <input
            type="text"
            id="username"
            name="username"
            value={formData.username}
            onChange={handleChange}
            required
            minLength={3}
            placeholder="Choose a username"
            className="form-input"
          />
        </div>

        <div className="form-group">
          <label htmlFor="email">Email Address</label>
          <input
            type="email"
            id="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            required
            placeholder="Enter your email"
            className="form-input"
          />
        </div>

        <div className="form-group">
          <label htmlFor="password">Password</label>
          <input
            type="password"
            id="password"
            name="password"
            value={formData.password}
            onChange={handleChange}
            required
            minLength={8}
            placeholder="Create a strong password"
            className="form-input"
          />
          {formData.password && (
            <div className="password-strength">
              <div className="strength-bar">
                <div 
                  className="strength-fill"
                  style={{
                    width: `${(passwordStrength / 5) * 100}%`,
                    backgroundColor: getStrengthColor()
                  }}
                ></div>
              </div>
              <span 
                className="strength-text"
                style={{ color: getStrengthColor() }}
              >
                {getStrengthText()}
              </span>
            </div>
          )}
        </div>

        <div className="form-group">
          <label htmlFor="confirmPassword">Confirm Password</label>
          <input
            type="password"
            id="confirmPassword"
            name="confirmPassword"
            value={formData.confirmPassword}
            onChange={handleChange}
            required
            placeholder="Confirm your password"
            className="form-input"
          />
        </div>

        <button
          type="submit"
          disabled={loading || passwordStrength < 3}
          className="auth-button primary"
        >
          {loading ? (
            <span className="loading-spinner">
              <span className="spinner"></span>
              Creating Account...
            </span>
          ) : (
            'Create Account'
          )}
        </button>

        <div className="auth-footer">
          <p>
            Already have an account?{' '}
            <button
              type="button"
              onClick={onSwitchToLogin}
              className="link-button"
            >
              Sign In
            </button>
          </p>
        </div>
      </form>
    </div>
  )
}