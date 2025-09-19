-- Create basketball management schema for ExpressCoach app
-- This migration sets up tables for clubs, teams, players, coaches, schedules, and notifications

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create clubs table (Express United is the single club)
CREATE TABLE public.clubs (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    code text NOT NULL UNIQUE,
    address text,
    phone text,
    email text,
    website text,
    logo_url text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Create teams table
CREATE TABLE public.teams (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id uuid NOT NULL REFERENCES public.clubs(id) ON DELETE CASCADE,
    name text NOT NULL,
    age_group text NOT NULL,
    season text NOT NULL,
    team_code text NOT NULL UNIQUE, -- 6-character alphanumeric code
    max_players integer DEFAULT 15,
    practice_location text,
    practice_schedule text,
    team_color text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT valid_team_code CHECK (length(team_code) = 6 AND team_code ~ '^[A-Z0-9]{6}$')
);

-- Create coaches table
CREATE TABLE public.coaches (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id uuid NOT NULL REFERENCES public.clubs(id) ON DELETE CASCADE,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text,
    phone text,
    role text NOT NULL DEFAULT 'coach', -- coach, director, assistant
    is_active boolean DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT valid_coach_role CHECK (role IN ('coach', 'director', 'assistant'))
);

-- Create players table
CREATE TABLE public.players (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name text NOT NULL,
    last_name text NOT NULL,
    jersey_number integer,
    position text,
    grade_level text,
    school text,
    parent_name text,
    parent_phone text,
    parent_email text,
    emergency_contact text,
    emergency_phone text,
    medical_notes text,
    is_active boolean DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT valid_jersey_number CHECK (jersey_number >= 0 AND jersey_number <= 99)
);

-- Create schedules table for practices and games
CREATE TABLE public.schedules (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id uuid NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
    title text NOT NULL,
    description text,
    event_type text NOT NULL, -- practice, game, tournament, meeting
    location text NOT NULL,
    start_time timestamptz NOT NULL,
    end_time timestamptz NOT NULL,
    is_recurring boolean DEFAULT false,
    recurrence_pattern text, -- weekly, daily, etc.
    opponent text, -- for games
    home_away text, -- home, away, neutral
    is_cancelled boolean DEFAULT false,
    cancelled_reason text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT valid_event_type CHECK (event_type IN ('practice', 'game', 'tournament', 'meeting', 'other')),
    CONSTRAINT valid_home_away CHECK (home_away IN ('home', 'away', 'neutral') OR home_away IS NULL),
    CONSTRAINT valid_time_range CHECK (end_time > start_time)
);

-- Create notifications table for tracking sent messages
CREATE TABLE public.notifications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id uuid NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
    sender_id uuid NOT NULL REFERENCES public.coaches(id) ON DELETE CASCADE,
    title text NOT NULL,
    message text NOT NULL,
    notification_type text NOT NULL DEFAULT 'general', -- general, schedule, roster, emergency
    target_audience text NOT NULL DEFAULT 'parents', -- parents, coaches, all
    schedule_id uuid REFERENCES public.schedules(id) ON DELETE SET NULL, -- if related to schedule
    sent_at timestamptz NOT NULL DEFAULT now(),
    read_count integer DEFAULT 0,
    delivery_status text DEFAULT 'sent', -- sent, delivered, failed
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT valid_notification_type CHECK (notification_type IN ('general', 'schedule', 'roster', 'emergency', 'announcement')),
    CONSTRAINT valid_target_audience CHECK (target_audience IN ('parents', 'coaches', 'all'))
);

-- Create coach_teams junction table (coaches can manage multiple teams)
CREATE TABLE public.coach_teams (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    coach_id uuid NOT NULL REFERENCES public.coaches(id) ON DELETE CASCADE,
    team_id uuid NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
    role text NOT NULL DEFAULT 'coach', -- head_coach, assistant_coach, coordinator
    assigned_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(coach_id, team_id),
    CONSTRAINT valid_coach_team_role CHECK (role IN ('head_coach', 'assistant_coach', 'coordinator', 'director'))
);

-- Create player_teams junction table (players can be on multiple teams)
CREATE TABLE public.player_teams (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id uuid NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
    team_id uuid NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
    joined_at timestamptz NOT NULL DEFAULT now(),
    left_at timestamptz,
    is_active boolean DEFAULT true,
    jersey_number integer, -- team-specific jersey number
    position text, -- team-specific position
    UNIQUE(player_id, team_id),
    CONSTRAINT valid_team_jersey_number CHECK (jersey_number >= 0 AND jersey_number <= 99)
);

-- Create indexes for better performance
CREATE INDEX idx_teams_club_id ON public.teams(club_id);
CREATE INDEX idx_teams_team_code ON public.teams(team_code);
CREATE INDEX idx_coaches_club_id ON public.coaches(club_id);
CREATE INDEX idx_schedules_team_id ON public.schedules(team_id);
CREATE INDEX idx_schedules_start_time ON public.schedules(start_time);
CREATE INDEX idx_notifications_team_id ON public.notifications(team_id);
CREATE INDEX idx_notifications_sent_at ON public.notifications(sent_at);
CREATE INDEX idx_coach_teams_coach_id ON public.coach_teams(coach_id);
CREATE INDEX idx_coach_teams_team_id ON public.coach_teams(team_id);
CREATE INDEX idx_player_teams_player_id ON public.player_teams(player_id);
CREATE INDEX idx_player_teams_team_id ON public.player_teams(team_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers to all tables
CREATE TRIGGER update_clubs_updated_at BEFORE UPDATE ON public.clubs
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON public.teams
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_coaches_updated_at BEFORE UPDATE ON public.coaches
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON public.players
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON public.schedules
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON public.notifications
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE public.clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coaches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coach_teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_teams ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for public access (since app uses team codes, not user auth initially)
-- These policies allow read access to all authenticated users for now
-- In production, you'll want to restrict based on team membership

-- Clubs policies
CREATE POLICY "Enable read access for all users" ON public.clubs
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.clubs
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON public.clubs
    FOR UPDATE USING (true);

-- Teams policies
CREATE POLICY "Enable read access for all users" ON public.teams
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.teams
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON public.teams
    FOR UPDATE USING (true);

-- Coaches policies
CREATE POLICY "Enable read access for all users" ON public.coaches
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.coaches
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON public.coaches
    FOR UPDATE USING (true);

-- Players policies
CREATE POLICY "Enable read access for all users" ON public.players
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.players
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON public.players
    FOR UPDATE USING (true);

-- Schedules policies
CREATE POLICY "Enable read access for all users" ON public.schedules
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.schedules
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON public.schedules
    FOR UPDATE USING (true);

-- Notifications policies
CREATE POLICY "Enable read access for all users" ON public.notifications
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.notifications
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON public.notifications
    FOR UPDATE USING (true);

-- Junction table policies
CREATE POLICY "Enable read access for all users" ON public.coach_teams
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.coach_teams
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON public.coach_teams
    FOR UPDATE USING (true);

CREATE POLICY "Enable read access for all users" ON public.player_teams
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.player_teams
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON public.player_teams
    FOR UPDATE USING (true);

-- Create functions for team code validation
CREATE OR REPLACE FUNCTION public.generate_team_code()
RETURNS text AS $$
DECLARE
    characters text := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result text := '';
    i integer;
BEGIN
    FOR i IN 1..6 LOOP
        result := result || substr(characters, floor(random() * length(characters) + 1)::int, 1);
    END LOOP;

    -- Ensure uniqueness
    WHILE EXISTS (SELECT 1 FROM public.teams WHERE team_code = result) LOOP
        result := '';
        FOR i IN 1..6 LOOP
            result := result || substr(characters, floor(random() * length(characters) + 1)::int, 1);
        END LOOP;
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Create function to get team roster
CREATE OR REPLACE FUNCTION public.get_team_roster(team_uuid uuid)
RETURNS TABLE (
    player_id uuid,
    first_name text,
    last_name text,
    jersey_number integer,
    player_position text,
    grade_level text,
    joined_at timestamptz
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.first_name,
        p.last_name,
        pt.jersey_number,
        pt.position,
        p.grade_level,
        pt.joined_at
    FROM public.players p
    JOIN public.player_teams pt ON p.id = pt.player_id
    WHERE pt.team_id = team_uuid
    AND pt.is_active = true
    ORDER BY pt.jersey_number, p.last_name, p.first_name;
END;
$$ LANGUAGE plpgsql;

-- Create function to get team schedule
CREATE OR REPLACE FUNCTION public.get_team_schedule(team_uuid uuid, start_date timestamptz DEFAULT now())
RETURNS TABLE (
    schedule_id uuid,
    title text,
    event_type text,
    location text,
    start_time timestamptz,
    end_time timestamptz,
    opponent text,
    home_away text,
    is_cancelled boolean
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id,
        s.title,
        s.event_type,
        s.location,
        s.start_time,
        s.end_time,
        s.opponent,
        s.home_away,
        s.is_cancelled
    FROM public.schedules s
    WHERE s.team_id = team_uuid
    AND s.start_time >= start_date
    ORDER BY s.start_time;
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE public.clubs IS 'Basketball clubs/organizations';
COMMENT ON TABLE public.teams IS 'Teams within clubs, organized by age group and season';
COMMENT ON TABLE public.coaches IS 'Coaches and staff members';
COMMENT ON TABLE public.players IS 'Player roster information';
COMMENT ON TABLE public.schedules IS 'Practice and game schedules';
COMMENT ON TABLE public.notifications IS 'Sent notifications and announcements';
COMMENT ON TABLE public.coach_teams IS 'Many-to-many relationship between coaches and teams';
COMMENT ON TABLE public.player_teams IS 'Many-to-many relationship between players and teams';