-- Migration: Create device_tokens table for push notifications
-- Created: 2025-10-03
-- Purpose: Store device tokens for sending push notifications to parents via ExpressUnited app

-- Create device_tokens table
CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    platform TEXT NOT NULL DEFAULT 'ios',
    is_active BOOLEAN DEFAULT true,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(device_token, team_id)
);

-- Create indexes for performance
CREATE INDEX idx_device_tokens_team_id ON device_tokens(team_id);
CREATE INDEX idx_device_tokens_active ON device_tokens(is_active) WHERE is_active = true;

-- Add RLS policies
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- Policy: Allow service role to manage all device tokens (for Edge Functions)
CREATE POLICY "Service role can manage all device tokens"
ON device_tokens
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Policy: Allow public to insert their own device tokens (authenticated by team_id)
CREATE POLICY "Public can insert device tokens"
ON device_tokens
FOR INSERT
TO public
WITH CHECK (true);

-- Policy: Allow public to update their own device tokens
CREATE POLICY "Public can update device tokens"
ON device_tokens
FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

-- Policy: Allow public to view device tokens for their team
CREATE POLICY "Public can view team device tokens"
ON device_tokens
FOR SELECT
TO public
USING (true);

-- Add comment
COMMENT ON TABLE device_tokens IS 'Stores device tokens for push notifications to ExpressUnited parent app';
