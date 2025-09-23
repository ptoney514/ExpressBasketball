-- ExpressBasketball Database Schema
-- This schema supports both ExpressCoach (staff) and ExpressUnited (parent) apps

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Teams table (core entity)
CREATE TABLE IF NOT EXISTS teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_code VARCHAR(6) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    age_group VARCHAR(50) NOT NULL,
    coach_name VARCHAR(100) NOT NULL,
    coach_role VARCHAR(50) NOT NULL DEFAULT 'Head Coach',
    assistant_coaches TEXT[] DEFAULT '{}',
    primary_color VARCHAR(7) DEFAULT '#FF7113',
    secondary_color VARCHAR(7) DEFAULT '#000000',
    logo_url TEXT,
    practice_location TEXT,
    practice_time TEXT,
    home_venue TEXT,
    season_record VARCHAR(20) DEFAULT '0-0',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Players table
CREATE TABLE IF NOT EXISTS players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    jersey_number INTEGER,
    position VARCHAR(50),
    height VARCHAR(10),
    grade VARCHAR(20),
    date_of_birth DATE,
    parent_name VARCHAR(100),
    parent_email VARCHAR(255),
    parent_phone VARCHAR(20),
    emergency_contact VARCHAR(100),
    emergency_phone VARCHAR(20),
    medical_notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Schedules/Events table
CREATE TABLE IF NOT EXISTS schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL, -- game, practice, tournament, scrimmage, team_event
    opponent VARCHAR(100),
    location VARCHAR(255) NOT NULL,
    address TEXT,
    date TIMESTAMPTZ NOT NULL,
    arrival_time TIMESTAMPTZ,
    is_home BOOLEAN DEFAULT false,
    is_cancelled BOOLEAN DEFAULT false,
    notes TEXT,
    result VARCHAR(10), -- win, loss, tie
    team_score INTEGER,
    opponent_score INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Messages table (for coach-to-parent/player communication)
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    sender_id UUID, -- Will link to auth.users later
    sender_name VARCHAR(100) NOT NULL,
    sender_role VARCHAR(50) NOT NULL, -- coach, parent, player
    recipient_type VARCHAR(50) NOT NULL, -- team, player, parent, coach
    recipient_id UUID, -- Specific recipient if not team-wide
    recipient_name VARCHAR(100),
    subject VARCHAR(255),
    content TEXT NOT NULL,
    is_urgent BOOLEAN DEFAULT false,
    read_by UUID[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications table (for push notifications)
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- announcement, schedule_update, reminder, emergency
    priority VARCHAR(20) DEFAULT 'normal', -- low, normal, high, urgent
    target_audience VARCHAR(50) DEFAULT 'all', -- all, parents, players, coaches
    data JSONB DEFAULT '{}', -- Additional data for deep linking
    sent_at TIMESTAMPTZ,
    scheduled_for TIMESTAMPTZ,
    is_sent BOOLEAN DEFAULT false,
    send_push BOOLEAN DEFAULT true,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Push tokens table (for APNS)
CREATE TABLE IF NOT EXISTS push_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID, -- Will link to auth.users
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    device_token TEXT UNIQUE NOT NULL,
    platform VARCHAR(20) NOT NULL, -- ios, android
    app_version VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    last_used TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Announcements table (team-wide messages)
CREATE TABLE IF NOT EXISTS announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    priority VARCHAR(20) DEFAULT 'normal',
    is_pinned BOOLEAN DEFAULT false,
    expires_at TIMESTAMPTZ,
    created_by VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Team members table (for parent app access)
CREATE TABLE IF NOT EXISTS team_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id UUID, -- Will link to auth.users
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL, -- coach, assistant_coach, parent, player
    name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    is_verified BOOLEAN DEFAULT false,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(team_id, email)
);

-- Create indexes for better performance
CREATE INDEX idx_teams_code ON teams(team_code);
CREATE INDEX idx_players_team ON players(team_id);
CREATE INDEX idx_schedules_team ON schedules(team_id);
CREATE INDEX idx_schedules_date ON schedules(date);
CREATE INDEX idx_messages_team ON messages(team_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);
CREATE INDEX idx_notifications_team ON notifications(team_id);
CREATE INDEX idx_notifications_sent ON notifications(is_sent, scheduled_for);
CREATE INDEX idx_push_tokens_user ON push_tokens(user_id);
CREATE INDEX idx_team_members_team ON team_members(team_id);
CREATE INDEX idx_team_members_user ON team_members(user_id);

-- Updated at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON announcements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();