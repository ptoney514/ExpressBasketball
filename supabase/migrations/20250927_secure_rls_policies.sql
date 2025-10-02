-- Secure Row Level Security Policies for ExpressBasketball
-- This migration replaces permissive policies with proper coach-based access control

-- First, drop all existing permissive policies
DROP POLICY IF EXISTS "Enable read access for all users" ON teams;
DROP POLICY IF EXISTS "Enable insert for all users" ON teams;
DROP POLICY IF EXISTS "Enable update for all users" ON teams;
DROP POLICY IF EXISTS "Enable delete for all users" ON teams;

DROP POLICY IF EXISTS "Enable read access for all users" ON players;
DROP POLICY IF EXISTS "Enable insert for all users" ON players;
DROP POLICY IF EXISTS "Enable update for all users" ON players;
DROP POLICY IF EXISTS "Enable delete for all users" ON players;

DROP POLICY IF EXISTS "Enable read access for all users" ON schedules;
DROP POLICY IF EXISTS "Enable insert for all users" ON schedules;
DROP POLICY IF EXISTS "Enable update for all users" ON schedules;
DROP POLICY IF EXISTS "Enable delete for all users" ON schedules;

DROP POLICY IF EXISTS "Enable read access for all users" ON events;
DROP POLICY IF EXISTS "Enable insert for all users" ON events;
DROP POLICY IF EXISTS "Enable update for all users" ON events;
DROP POLICY IF EXISTS "Enable delete for all users" ON events;

DROP POLICY IF EXISTS "Enable read access for all users" ON announcements;
DROP POLICY IF EXISTS "Enable insert for all users" ON announcements;
DROP POLICY IF EXISTS "Enable update for all users" ON announcements;
DROP POLICY IF EXISTS "Enable delete for all users" ON announcements;

DROP POLICY IF EXISTS "Enable read access for all users" ON attendance;
DROP POLICY IF EXISTS "Enable insert for all users" ON attendance;
DROP POLICY IF EXISTS "Enable update for all users" ON attendance;
DROP POLICY IF EXISTS "Enable delete for all users" ON attendance;

DROP POLICY IF EXISTS "Enable read access for all users" ON player_stats;
DROP POLICY IF EXISTS "Enable insert for all users" ON player_stats;
DROP POLICY IF EXISTS "Enable update for all users" ON player_stats;
DROP POLICY IF EXISTS "Enable delete for all users" ON player_stats;

-- ==============================================
-- COACHES TABLE POLICIES
-- ==============================================
-- Coaches can view their own profile
CREATE POLICY "coaches_view_own" ON coaches
    FOR SELECT USING (auth.uid() = user_id);

-- Coaches can update their own profile
CREATE POLICY "coaches_update_own" ON coaches
    FOR UPDATE USING (auth.uid() = user_id);

-- New coaches can insert their profile after signup
CREATE POLICY "coaches_insert_own" ON coaches
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ==============================================
-- TEAMS TABLE POLICIES
-- ==============================================
-- Coaches can view teams they are associated with OR teams with a valid team code (for parents)
CREATE POLICY "teams_view_accessible" ON teams
    FOR SELECT USING (
        -- Coach has access
        EXISTS (
            SELECT 1 FROM coach_teams ct
            JOIN coaches c ON c.id = ct.coach_id
            WHERE ct.team_id = teams.id
            AND c.user_id = auth.uid()
        )
        OR 
        -- Team has a public team code (for parent app access)
        team_code IS NOT NULL
    );

-- Authenticated coaches can create new teams
CREATE POLICY "teams_insert_authenticated" ON teams
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM coaches
            WHERE user_id = auth.uid()
        )
    );

-- Coaches can update teams they own or admin
CREATE POLICY "teams_update_owned" ON teams
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM coach_teams ct
            JOIN coaches c ON c.id = ct.coach_id
            WHERE ct.team_id = teams.id
            AND c.user_id = auth.uid()
            AND ct.role IN ('owner', 'admin')
        )
    );

-- Only team owners can delete teams
CREATE POLICY "teams_delete_owner" ON teams
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM coach_teams ct
            JOIN coaches c ON c.id = ct.coach_id
            WHERE ct.team_id = teams.id
            AND c.user_id = auth.uid()
            AND ct.role = 'owner'
        )
    );

-- ==============================================
-- COACH_TEAMS TABLE POLICIES
-- ==============================================
-- Coaches can view their own associations
CREATE POLICY "coach_teams_view_own" ON coach_teams
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM coaches
            WHERE coaches.id = coach_teams.coach_id
            AND coaches.user_id = auth.uid()
        )
    );

-- Coaches can create associations when they create a team
CREATE POLICY "coach_teams_insert_own" ON coach_teams
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM coaches
            WHERE coaches.id = coach_teams.coach_id
            AND coaches.user_id = auth.uid()
        )
    );

-- ==============================================
-- PLAYERS TABLE POLICIES
-- ==============================================
-- View players: coaches of the team OR public via team code
CREATE POLICY "players_view_accessible" ON players
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM teams t
            LEFT JOIN coach_teams ct ON ct.team_id = t.id
            LEFT JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = players.team_id
            AND (c.user_id = auth.uid() OR t.team_code IS NOT NULL)
        )
    );

-- Coaches can insert players to their teams
CREATE POLICY "players_insert_owned_team" ON players
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM teams t
            JOIN coach_teams ct ON ct.team_id = t.id
            JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = players.team_id
            AND c.user_id = auth.uid()
            AND ct.role IN ('owner', 'admin')
        )
    );

-- Coaches can update players on their teams
CREATE POLICY "players_update_owned_team" ON players
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM teams t
            JOIN coach_teams ct ON ct.team_id = t.id
            JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = players.team_id
            AND c.user_id = auth.uid()
            AND ct.role IN ('owner', 'admin')
        )
    );

-- Coaches can delete players from their teams
CREATE POLICY "players_delete_owned_team" ON players
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM teams t
            JOIN coach_teams ct ON ct.team_id = t.id
            JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = players.team_id
            AND c.user_id = auth.uid()
            AND ct.role IN ('owner', 'admin')
        )
    );

-- ==============================================
-- SCHEDULES TABLE POLICIES
-- ==============================================
-- View schedules: coaches of the team OR public via team code
CREATE POLICY "schedules_view_accessible" ON schedules
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM teams t
            LEFT JOIN coach_teams ct ON ct.team_id = t.id
            LEFT JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = schedules.team_id
            AND (c.user_id = auth.uid() OR t.team_code IS NOT NULL)
        )
    );

-- Coaches can manage schedules for their teams
CREATE POLICY "schedules_insert_owned_team" ON schedules
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM teams t
            JOIN coach_teams ct ON ct.team_id = t.id
            JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = schedules.team_id
            AND c.user_id = auth.uid()
            AND ct.role IN ('owner', 'admin')
        )
    );

CREATE POLICY "schedules_update_owned_team" ON schedules
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM teams t
            JOIN coach_teams ct ON ct.team_id = t.id
            JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = schedules.team_id
            AND c.user_id = auth.uid()
            AND ct.role IN ('owner', 'admin')
        )
    );

CREATE POLICY "schedules_delete_owned_team" ON schedules
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM teams t
            JOIN coach_teams ct ON ct.team_id = t.id
            JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = schedules.team_id
            AND c.user_id = auth.uid()
            AND ct.role IN ('owner', 'admin')
        )
    );

-- ==============================================
-- EVENTS TABLE POLICIES
-- ==============================================
-- View events: coaches of the team OR public via team code
CREATE POLICY "events_view_accessible" ON events
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM teams t
            LEFT JOIN coach_teams ct ON ct.team_id = t.id
            LEFT JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = events.team_id
            AND (c.user_id = auth.uid() OR t.team_code IS NOT NULL)
        )
    );

-- Coaches can manage events for their teams
CREATE POLICY "events_manage_owned_team" ON events
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM teams t
            JOIN coach_teams ct ON ct.team_id = t.id
            JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = events.team_id
            AND c.user_id = auth.uid()
            AND ct.role IN ('owner', 'admin')
        )
    );

-- ==============================================
-- ANNOUNCEMENTS TABLE POLICIES
-- ==============================================
-- View announcements: coaches of the team OR public via team code
CREATE POLICY "announcements_view_accessible" ON announcements
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM teams t
            LEFT JOIN coach_teams ct ON ct.team_id = t.id
            LEFT JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = announcements.team_id
            AND (c.user_id = auth.uid() OR t.team_code IS NOT NULL)
        )
    );

-- Coaches can manage announcements for their teams
CREATE POLICY "announcements_manage_owned_team" ON announcements
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM teams t
            JOIN coach_teams ct ON ct.team_id = t.id
            JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = announcements.team_id
            AND c.user_id = auth.uid()
            AND ct.role IN ('owner', 'admin')
        )
    );

-- ==============================================
-- MESSAGES TABLE POLICIES
-- ==============================================
-- View messages: coaches of the team OR recipients via team code
CREATE POLICY "messages_view_accessible" ON messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM teams t
            LEFT JOIN coach_teams ct ON ct.team_id = t.id
            LEFT JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = messages.team_id
            AND (c.user_id = auth.uid() OR t.team_code IS NOT NULL)
        )
    );

-- Coaches can send messages to their teams
CREATE POLICY "messages_insert_coach" ON messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM teams t
            JOIN coach_teams ct ON ct.team_id = t.id
            JOIN coaches c ON c.id = ct.coach_id
            WHERE t.id = messages.team_id
            AND c.user_id = auth.uid()
            AND ct.role IN ('owner', 'admin')
        )
    );

-- Coaches can update their own messages
CREATE POLICY "messages_update_own" ON messages
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM coaches c
            WHERE c.id = messages.coach_id
            AND c.user_id = auth.uid()
        )
    );

-- ==============================================
-- VENUES TABLE POLICIES
-- ==============================================
-- Anyone can view venues (public information)
CREATE POLICY "venues_view_all" ON venues
    FOR SELECT USING (true);

-- Authenticated coaches can manage venues
CREATE POLICY "venues_manage_authenticated" ON venues
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM coaches
            WHERE user_id = auth.uid()
        )
    );

-- ==============================================
-- HOTELS TABLE POLICIES
-- ==============================================
-- Anyone can view hotels (public information)
CREATE POLICY "hotels_view_all" ON hotels
    FOR SELECT USING (true);

-- Authenticated coaches can manage hotels
CREATE POLICY "hotels_manage_authenticated" ON hotels
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM coaches
            WHERE user_id = auth.uid()
        )
    );

-- ==============================================
-- SYNC_METADATA TABLE POLICIES
-- ==============================================
-- Users can only see their own sync metadata
CREATE POLICY "sync_metadata_own" ON sync_metadata
    FOR ALL USING (
        client_id = auth.uid()::text
    );

-- ==============================================
-- PUSH_TOKENS TABLE POLICIES
-- ==============================================
-- Users can manage their own push tokens
CREATE POLICY "push_tokens_own" ON push_tokens
    FOR ALL USING (
        user_id = auth.uid()
        OR
        -- Allow anonymous users with valid team code to register tokens
        (user_id IS NULL AND team_code IN (SELECT team_code FROM teams WHERE team_code IS NOT NULL))
    );

-- ==============================================
-- ATTENDANCE TABLE POLICIES (keeping simple for now)
-- ==============================================
-- Coaches can manage attendance for their teams
CREATE POLICY "attendance_manage_coach" ON attendance
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM schedules s
            JOIN teams t ON t.id = s.team_id
            JOIN coach_teams ct ON ct.team_id = t.id
            JOIN coaches c ON c.id = ct.coach_id
            WHERE s.id = attendance.schedule_id
            AND c.user_id = auth.uid()
        )
    );

-- ==============================================
-- PLAYER_STATS TABLE POLICIES
-- ==============================================
-- View stats: anyone with team access
CREATE POLICY "player_stats_view" ON player_stats
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM players p
            JOIN teams t ON t.id = p.team_id
            LEFT JOIN coach_teams ct ON ct.team_id = t.id
            LEFT JOIN coaches c ON c.id = ct.coach_id
            WHERE p.id = player_stats.player_id
            AND (c.user_id = auth.uid() OR t.team_code IS NOT NULL)
        )
    );

-- Coaches can manage stats for their teams
CREATE POLICY "player_stats_manage_coach" ON player_stats
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM players p
            JOIN teams t ON t.id = p.team_id
            JOIN coach_teams ct ON ct.team_id = t.id
            JOIN coaches c ON c.id = ct.coach_id
            WHERE p.id = player_stats.player_id
            AND c.user_id = auth.uid()
            AND ct.role IN ('owner', 'admin')
        )
    );