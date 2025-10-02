-- Production schema enhancements for ExpressBasketball
-- This migration adds coach relationships, sync metadata, and venues/hotels

-- Create coaches table (links auth users to their coaching profile)
CREATE TABLE IF NOT EXISTS coaches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    phone TEXT,
    role TEXT CHECK (role IN ('head_coach', 'assistant_coach', 'director')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Create coach-team relationship table
CREATE TABLE IF NOT EXISTS coach_teams (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    coach_id UUID NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    role TEXT CHECK (role IN ('owner', 'admin', 'viewer')) DEFAULT 'owner',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(coach_id, team_id)
);

-- Sync metadata for offline-first architecture
CREATE TABLE IF NOT EXISTS sync_metadata (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    client_id TEXT NOT NULL,
    last_synced_at TIMESTAMPTZ DEFAULT NOW(),
    sync_version INTEGER DEFAULT 1,
    is_deleted BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(table_name, record_id, client_id)
);

-- Venues table for game/practice locations
CREATE TABLE IF NOT EXISTS venues (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    street_address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    full_address TEXT GENERATED ALWAYS AS (street_address || ', ' || city || ', ' || state || ' ' || zip_code) STORED,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    phone TEXT,
    website TEXT,
    capacity INTEGER,
    court_count INTEGER,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Hotels table for tournament accommodations
CREATE TABLE IF NOT EXISTS hotels (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    brand_name TEXT,
    street_address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    phone TEXT NOT NULL,
    website TEXT,
    distance_from_venue DOUBLE PRECISION,
    team_rate DECIMAL(10,2),
    team_rate_code TEXT,
    booking_instructions TEXT,
    check_in_time TIME,
    check_out_time TIME,
    amenities JSONB DEFAULT '[]',
    is_official_hotel BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add missing columns to existing teams table
ALTER TABLE teams ADD COLUMN IF NOT EXISTS coach_id UUID REFERENCES coaches(id);
ALTER TABLE teams ADD COLUMN IF NOT EXISTS coach_name TEXT;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS coach_email TEXT;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS coach_phone TEXT;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS assistant_coaches JSONB DEFAULT '[]';
ALTER TABLE teams ADD COLUMN IF NOT EXISTS practice_location TEXT;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS practice_time TEXT;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS home_venue TEXT;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS season_record TEXT DEFAULT '0-0';
ALTER TABLE teams ADD COLUMN IF NOT EXISTS wins INTEGER DEFAULT 0;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS losses INTEGER DEFAULT 0;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ;

-- Add sync columns to players table
ALTER TABLE players ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ;
ALTER TABLE players ADD COLUMN IF NOT EXISTS sync_version INTEGER DEFAULT 1;

-- Add venue relationships to schedules and events
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS venue_id UUID REFERENCES venues(id);
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ;
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS sync_version INTEGER DEFAULT 1;

ALTER TABLE events ADD COLUMN IF NOT EXISTS venue_id UUID REFERENCES venues(id);
ALTER TABLE events ADD COLUMN IF NOT EXISTS hotel_id UUID REFERENCES hotels(id);
ALTER TABLE events ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ;
ALTER TABLE events ADD COLUMN IF NOT EXISTS sync_version INTEGER DEFAULT 1;

-- Add sync columns to announcements
ALTER TABLE announcements ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ;
ALTER TABLE announcements ADD COLUMN IF NOT EXISTS sync_version INTEGER DEFAULT 1;
ALTER TABLE announcements ADD COLUMN IF NOT EXISTS coach_id UUID REFERENCES coaches(id);

-- Messages table for team communication
CREATE TABLE IF NOT EXISTS messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    coach_id UUID REFERENCES coaches(id),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    message_type TEXT CHECK (message_type IN ('announcement', 'reminder', 'urgent', 'general')) DEFAULT 'general',
    recipients JSONB DEFAULT '{"all": true}', -- Can specify specific players or parents
    read_by JSONB DEFAULT '[]', -- Track who has read the message
    is_pinned BOOLEAN DEFAULT false,
    scheduled_for TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Push notification tokens for message delivery
CREATE TABLE IF NOT EXISTS push_tokens (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    team_code TEXT,
    token TEXT NOT NULL UNIQUE,
    platform TEXT CHECK (platform IN ('ios', 'android')) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_coaches_user_id ON coaches(user_id);
CREATE INDEX IF NOT EXISTS idx_coach_teams_coach_id ON coach_teams(coach_id);
CREATE INDEX IF NOT EXISTS idx_coach_teams_team_id ON coach_teams(team_id);
CREATE INDEX IF NOT EXISTS idx_sync_metadata_lookup ON sync_metadata(table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_messages_team_id ON messages(team_id);
CREATE INDEX IF NOT EXISTS idx_messages_sent_at ON messages(sent_at);
CREATE INDEX IF NOT EXISTS idx_push_tokens_team_code ON push_tokens(team_code);

-- Enable RLS on new tables
ALTER TABLE coaches ENABLE ROW LEVEL SECURITY;
ALTER TABLE coach_teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_metadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE venues ENABLE ROW LEVEL SECURITY;
ALTER TABLE hotels ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;

-- Create triggers for updated_at on new tables
CREATE TRIGGER update_coaches_updated_at BEFORE UPDATE ON coaches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_coach_teams_updated_at BEFORE UPDATE ON coach_teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sync_metadata_updated_at BEFORE UPDATE ON sync_metadata
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_venues_updated_at BEFORE UPDATE ON venues
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_hotels_updated_at BEFORE UPDATE ON hotels
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_push_tokens_updated_at BEFORE UPDATE ON push_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();