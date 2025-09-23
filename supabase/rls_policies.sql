-- Row Level Security Policies for ExpressBasketball
-- These policies control who can access what data

-- Enable RLS on all tables
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

-- TEAMS POLICIES
-- Anyone can view teams (needed for team code validation)
CREATE POLICY "Teams are viewable by everyone"
    ON teams FOR SELECT
    USING (true);

-- Only coaches can create teams (will add auth later)
CREATE POLICY "Coaches can create teams"
    ON teams FOR INSERT
    WITH CHECK (true); -- Will update with auth

-- Only team coaches can update their teams
CREATE POLICY "Coaches can update their teams"
    ON teams FOR UPDATE
    USING (true); -- Will update with auth

-- PLAYERS POLICIES
-- Team members can view players
CREATE POLICY "Team members can view players"
    ON players FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM team_members
            WHERE team_members.team_id = players.team_id
        )
        OR true -- Temporarily allow all for development
    );

-- Coaches can manage players
CREATE POLICY "Coaches can insert players"
    ON players FOR INSERT
    WITH CHECK (true); -- Will update with auth

CREATE POLICY "Coaches can update players"
    ON players FOR UPDATE
    USING (true); -- Will update with auth

CREATE POLICY "Coaches can delete players"
    ON players FOR DELETE
    USING (true); -- Will update with auth

-- SCHEDULES POLICIES
-- Team members can view schedules
CREATE POLICY "Team members can view schedules"
    ON schedules FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM team_members
            WHERE team_members.team_id = schedules.team_id
        )
        OR true -- Temporarily allow all for development
    );

-- Coaches can manage schedules
CREATE POLICY "Coaches can insert schedules"
    ON schedules FOR INSERT
    WITH CHECK (true); -- Will update with auth

CREATE POLICY "Coaches can update schedules"
    ON schedules FOR UPDATE
    USING (true); -- Will update with auth

CREATE POLICY "Coaches can delete schedules"
    ON schedules FOR DELETE
    USING (true); -- Will update with auth

-- MESSAGES POLICIES
-- Team members can view messages for their team
CREATE POLICY "Team members can view messages"
    ON messages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM team_members
            WHERE team_members.team_id = messages.team_id
        )
        OR true -- Temporarily allow all for development
    );

-- Anyone can send messages (with proper validation)
CREATE POLICY "Users can send messages"
    ON messages FOR INSERT
    WITH CHECK (true); -- Will update with auth

-- NOTIFICATIONS POLICIES
-- Team members can view notifications
CREATE POLICY "Team members can view notifications"
    ON notifications FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM team_members
            WHERE team_members.team_id = notifications.team_id
        )
        OR true -- Temporarily allow all for development
    );

-- Coaches can create notifications
CREATE POLICY "Coaches can create notifications"
    ON notifications FOR INSERT
    WITH CHECK (true); -- Will update with auth

-- PUSH TOKENS POLICIES
-- Users can manage their own push tokens
CREATE POLICY "Users can view own push tokens"
    ON push_tokens FOR SELECT
    USING (true); -- Will update with auth

CREATE POLICY "Users can insert own push tokens"
    ON push_tokens FOR INSERT
    WITH CHECK (true); -- Will update with auth

CREATE POLICY "Users can update own push tokens"
    ON push_tokens FOR UPDATE
    USING (true); -- Will update with auth

CREATE POLICY "Users can delete own push tokens"
    ON push_tokens FOR DELETE
    USING (true); -- Will update with auth

-- ANNOUNCEMENTS POLICIES
-- Team members can view announcements
CREATE POLICY "Team members can view announcements"
    ON announcements FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM team_members
            WHERE team_members.team_id = announcements.team_id
        )
        OR true -- Temporarily allow all for development
    );

-- Coaches can manage announcements
CREATE POLICY "Coaches can create announcements"
    ON announcements FOR INSERT
    WITH CHECK (true); -- Will update with auth

CREATE POLICY "Coaches can update announcements"
    ON announcements FOR UPDATE
    USING (true); -- Will update with auth

CREATE POLICY "Coaches can delete announcements"
    ON announcements FOR DELETE
    USING (true); -- Will update with auth

-- TEAM MEMBERS POLICIES
-- Anyone can view team members (for validation)
CREATE POLICY "Team members are viewable"
    ON team_members FOR SELECT
    USING (true);

-- Anyone can join a team (with valid code)
CREATE POLICY "Users can join teams"
    ON team_members FOR INSERT
    WITH CHECK (true);

-- Users can update their own membership
CREATE POLICY "Users can update own membership"
    ON team_members FOR UPDATE
    USING (true); -- Will update with auth

-- Note: These policies are initially permissive for development
-- They should be tightened with proper auth.users integration in production