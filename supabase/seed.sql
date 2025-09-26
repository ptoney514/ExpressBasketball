-- Seed data for development and testing

-- Insert a demo team
INSERT INTO teams (id, name, team_code, organization, age_group, season, primary_color, secondary_color)
VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Thunder Elite', 'THDR01', 'Express Basketball Club', '14U', '2024-2025', '#007AFF', '#FF3B30'),
    ('550e8400-e29b-41d4-a716-446655440002', 'Lightning Squad', 'LTNG02', 'Express Basketball Club', '12U', '2024-2025', '#34C759', '#FF9500');

-- Insert demo players for Thunder Elite
INSERT INTO players (team_id, jersey_number, first_name, last_name, position, height, weight, date_of_birth, parent_name, parent_email, parent_phone)
VALUES
    ('550e8400-e29b-41d4-a716-446655440001', '23', 'Michael', 'Johnson', 'Guard', '5''10"', '140', '2010-03-15', 'David Johnson', 'djohnson@email.com', '555-0101'),
    ('550e8400-e29b-41d4-a716-446655440001', '12', 'Sarah', 'Williams', 'Forward', '5''8"', '135', '2010-05-22', 'Lisa Williams', 'lwilliams@email.com', '555-0102'),
    ('550e8400-e29b-41d4-a716-446655440001', '7', 'James', 'Brown', 'Center', '6''1"', '155', '2010-01-10', 'Robert Brown', 'rbrown@email.com', '555-0103'),
    ('550e8400-e29b-41d4-a716-446655440001', '15', 'Emma', 'Davis', 'Guard', '5''6"', '125', '2010-07-18', 'Jennifer Davis', 'jdavis@email.com', '555-0104'),
    ('550e8400-e29b-41d4-a716-446655440001', '9', 'Noah', 'Miller', 'Forward', '5''11"', '145', '2010-09-05', 'Thomas Miller', 'tmiller@email.com', '555-0105');

-- Insert demo players for Lightning Squad
INSERT INTO players (team_id, jersey_number, first_name, last_name, position, height, weight, date_of_birth, parent_name, parent_email, parent_phone)
VALUES
    ('550e8400-e29b-41d4-a716-446655440002', '5', 'Olivia', 'Garcia', 'Guard', '5''4"', '115', '2012-02-14', 'Maria Garcia', 'mgarcia@email.com', '555-0201'),
    ('550e8400-e29b-41d4-a716-446655440002', '11', 'Liam', 'Martinez', 'Forward', '5''7"', '125', '2012-04-20', 'Carlos Martinez', 'cmartinez@email.com', '555-0202'),
    ('550e8400-e29b-41d4-a716-446655440002', '22', 'Ava', 'Rodriguez', 'Center', '5''9"', '130', '2012-06-08', 'Ana Rodriguez', 'arodriguez@email.com', '555-0203');

-- Insert demo schedules for Thunder Elite
INSERT INTO schedules (team_id, title, event_type, start_time, end_time, location, address, opponent, is_home_game, notes)
VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Practice - Fundamentals', 'practice', '2025-09-28 16:00:00', '2025-09-28 18:00:00', 'Express Sports Complex', '123 Main St, Springfield', NULL, true, 'Focus on defensive drills and free throws'),
    ('550e8400-e29b-41d4-a716-446655440001', 'vs. Warriors Academy', 'game', '2025-09-30 18:00:00', '2025-09-30 20:00:00', 'Express Sports Complex', '123 Main St, Springfield', 'Warriors Academy', true, 'First home game of the season'),
    ('550e8400-e29b-41d4-a716-446655440001', 'at Rockets Elite', 'game', '2025-10-02 19:00:00', '2025-10-02 21:00:00', 'Rockets Arena', '456 Oak Ave, Riverside', 'Rockets Elite', false, 'Bring white jerseys'),
    ('550e8400-e29b-41d4-a716-446655440001', 'Practice - Game Prep', 'practice', '2025-10-05 16:00:00', '2025-10-05 17:30:00', 'Express Sports Complex', '123 Main St, Springfield', NULL, true, 'Preparation for tournament');

-- Insert demo schedules for Lightning Squad
INSERT INTO schedules (team_id, title, event_type, start_time, end_time, location, address, opponent, is_home_game, notes)
VALUES
    ('550e8400-e29b-41d4-a716-446655440002', 'Practice - Skills Development', 'practice', '2025-09-27 15:00:00', '2025-09-27 16:30:00', 'Express Sports Complex', '123 Main St, Springfield', NULL, true, 'Ball handling and shooting drills'),
    ('550e8400-e29b-41d4-a716-446655440002', 'vs. Storm Youth', 'game', '2025-09-29 14:00:00', '2025-09-29 15:30:00', 'Express Sports Complex', '123 Main St, Springfield', 'Storm Youth', true, 'Opening game');

-- Insert demo events
INSERT INTO events (team_id, title, description, start_date, end_date, location, event_type, rsvp_required)
VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Team Pizza Party', 'End of season celebration for all players and families', '2025-10-15 18:00:00', '2025-10-15 20:00:00', 'Pizza Palace - 789 Elm St', 'event', true),
    ('550e8400-e29b-41d4-a716-446655440001', 'Fall Tournament', 'Express Basketball Fall Classic Tournament', '2025-10-20 08:00:00', '2025-10-21 18:00:00', 'Regional Sports Center', 'tournament', true);

-- Insert demo announcements
INSERT INTO announcements (team_id, title, content, priority, is_pinned, created_by)
VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Welcome to the 2024-2025 Season!', 'We are excited to kick off another great season of Express Basketball. Please make sure to review the team schedule and bring all required equipment to the first practice.', 'high', true, 'Coach Smith'),
    ('550e8400-e29b-41d4-a716-446655440001', 'Uniform Orders Due', 'Please submit your uniform orders by September 30th. Order forms are available at practice or can be downloaded from the team website.', 'normal', false, 'Team Manager'),
    ('550e8400-e29b-41d4-a716-446655440002', 'Practice Schedule Update', 'Saturday practices will now start at 3:00 PM instead of 2:00 PM for the remainder of September.', 'high', true, 'Coach Johnson');