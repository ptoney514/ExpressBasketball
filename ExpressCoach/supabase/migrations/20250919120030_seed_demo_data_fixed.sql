-- Seed data for Express United Basketball Club with proper UUID formatting
-- This migration creates demo data for the ExpressCoach app

-- Insert Express United club
INSERT INTO public.clubs (id, name, code, address, phone, email, website)
VALUES (
    uuid_generate_v4(),
    'Express United Basketball',
    'EXPUNI',
    '123 Basketball Lane, Monroe, MS 39110',
    '(601) 555-0100',
    'info@expressunited.com',
    'https://expressunited.com'
);

-- Store club ID for reference
DO $$
DECLARE
    club_uuid uuid;
    coach_foster uuid := uuid_generate_v4();
    coach_grixby uuid := uuid_generate_v4();
    coach_evans uuid := uuid_generate_v4();
    coach_perry uuid := uuid_generate_v4();
    coach_todd uuid := uuid_generate_v4();
    coach_scott uuid := uuid_generate_v4();
    coach_mitchell uuid := uuid_generate_v4();
    team_4th_foster uuid := uuid_generate_v4();
    team_4th_grixby uuid := uuid_generate_v4();
    team_5th_perry uuid := uuid_generate_v4();
    team_6th_todd uuid := uuid_generate_v4();
    team_6th_scott uuid := uuid_generate_v4();
    team_7th uuid := uuid_generate_v4();
    team_7th_mitchell uuid := uuid_generate_v4();
    team_8th uuid := uuid_generate_v4();
    team_8th_mitchell uuid := uuid_generate_v4();
BEGIN
    -- Get the club ID we just inserted
    SELECT id INTO club_uuid FROM public.clubs WHERE code = 'EXPUNI';

    -- Insert coaches
    INSERT INTO public.coaches (id, club_id, first_name, last_name, email, phone, role) VALUES
    (coach_foster, club_uuid, 'Coach', 'Foster', 'foster@expressunited.com', '(601) 555-0101', 'coach'),
    (coach_grixby, club_uuid, 'Coach', 'Grixby', 'grixby@expressunited.com', '(601) 555-0102', 'coach'),
    (coach_evans, club_uuid, 'Coach', 'Evans', 'evans@expressunited.com', '(601) 555-0103', 'assistant'),
    (coach_perry, club_uuid, 'Coach', 'Perry', 'perry@expressunited.com', '(601) 555-0104', 'coach'),
    (coach_todd, club_uuid, 'Coach', 'Todd', 'todd@expressunited.com', '(601) 555-0105', 'coach'),
    (coach_scott, club_uuid, 'Coach', 'Scott', 'scott@expressunited.com', '(601) 555-0106', 'coach'),
    (coach_mitchell, club_uuid, 'Coach', 'Mitchell', 'mitchell@expressunited.com', '(601) 555-0107', 'coach');

    -- Insert teams
    INSERT INTO public.teams (id, club_id, name, age_group, season, team_code, practice_location, practice_schedule, team_color) VALUES
    (team_4th_foster, club_uuid, 'Express United 4th Foster', '4th Grade', '2024-25', 'EU4FST', 'Monroe MS', 'Mon/Wed 6:00-7:30 PM', 'Blue'),
    (team_4th_grixby, club_uuid, 'Express United 4th Grixby/Evans', '4th Grade', '2024-25', 'EU4GRX', 'Northwest HS', 'Tue/Thu 6:00-8:00 PM', 'Red'),
    (team_5th_perry, club_uuid, 'Express United 5th Perry', '5th Grade', '2024-25', 'EU5PRY', 'Northwest HS', 'Tue/Thu 6:00-8:00 PM', 'Green'),
    (team_6th_todd, club_uuid, 'Express United 6th Todd', '6th Grade', '2024-25', 'EU6TOD', 'McMillan MS / Monroe MS', 'Tue at McMillan 6:00-7:30, Thu at Monroe', 'Purple'),
    (team_6th_scott, club_uuid, 'Express United 6th Scott', '6th Grade', '2024-25', 'EU6SCT', 'McMillan MS / Central HS', 'Tue at McMillan 6:00-7:30, Wed at Central', 'Orange'),
    (team_7th, club_uuid, 'Express United 7th', '7th Grade', '2024-25', 'EU7TH1', 'Central HS', 'Mon/Wed 6:00-8:00 PM', 'Black'),
    (team_7th_mitchell, club_uuid, 'Express United 7th Mitchell', '7th Grade', '2024-25', 'EU7MIT', 'Central HS', 'Mon/Wed 6:00-8:00 PM', 'Gold'),
    (team_8th, club_uuid, 'Express United 8th', '8th Grade', '2024-25', 'EU8TH1', 'Central HS', 'Mon/Wed 6:00-8:00 PM', 'Navy'),
    (team_8th_mitchell, club_uuid, 'Express United 8th Mitchell', '8th Grade', '2024-25', 'EU8MIT', 'Central HS', 'Mon/Wed 6:00-8:00 PM', 'Silver');

    -- Insert coach-team assignments
    INSERT INTO public.coach_teams (coach_id, team_id, role) VALUES
    -- Foster coaches 4th Foster
    (coach_foster, team_4th_foster, 'head_coach'),
    -- Grixby and Evans coach 4th Grixby/Evans
    (coach_grixby, team_4th_grixby, 'head_coach'),
    (coach_evans, team_4th_grixby, 'assistant_coach'),
    -- Perry coaches 5th Perry
    (coach_perry, team_5th_perry, 'head_coach'),
    -- Todd coaches 6th Todd
    (coach_todd, team_6th_todd, 'head_coach'),
    -- Scott coaches 6th Scott
    (coach_scott, team_6th_scott, 'head_coach'),
    -- Mitchell coaches both 7th Mitchell and 8th Mitchell
    (coach_mitchell, team_7th_mitchell, 'head_coach'),
    (coach_mitchell, team_8th_mitchell, 'head_coach');

    -- Insert sample players for each team
    -- Express United 4th Foster (8 players)
    INSERT INTO public.players (first_name, last_name, jersey_number, position, grade_level, school, parent_name, parent_phone, parent_email) VALUES
    ('Marcus', 'Johnson', 10, 'Guard', '4th', 'Monroe Elementary', 'Lisa Johnson', '(601) 555-1001', 'lisa.johnson@email.com'),
    ('Tyler', 'Williams', 12, 'Forward', '4th', 'Monroe Elementary', 'Michael Williams', '(601) 555-1002', 'mike.williams@email.com'),
    ('Jordan', 'Brown', 15, 'Center', '4th', 'Oak Hill Elementary', 'Sarah Brown', '(601) 555-1003', 'sarah.brown@email.com'),
    ('Cameron', 'Davis', 8, 'Guard', '4th', 'Monroe Elementary', 'David Davis', '(601) 555-1004', 'david.davis@email.com'),
    ('Alex', 'Miller', 22, 'Forward', '4th', 'Pine Ridge Elementary', 'Jennifer Miller', '(601) 555-1005', 'jen.miller@email.com'),
    ('Jayden', 'Wilson', 5, 'Guard', '4th', 'Monroe Elementary', 'Robert Wilson', '(601) 555-1006', 'rob.wilson@email.com'),
    ('Ethan', 'Moore', 33, 'Forward', '4th', 'Oak Hill Elementary', 'Amanda Moore', '(601) 555-1007', 'amanda.moore@email.com'),
    ('Noah', 'Taylor', 7, 'Guard', '4th', 'Monroe Elementary', 'James Taylor', '(601) 555-1008', 'james.taylor@email.com');

    -- Insert player-team relationships for 4th Foster team
    INSERT INTO public.player_teams (player_id, team_id, jersey_number, position)
    SELECT p.id, team_4th_foster, p.jersey_number, p.position
    FROM public.players p
    WHERE p.first_name IN ('Marcus', 'Tyler', 'Jordan', 'Cameron', 'Alex', 'Jayden', 'Ethan', 'Noah')
    AND p.last_name IN ('Johnson', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor');

    -- Insert more players for other teams (abbreviated for demo)
    INSERT INTO public.players (first_name, last_name, jersey_number, position, grade_level, school, parent_name, parent_phone, parent_email) VALUES
    -- 4th Grixby/Evans team
    ('Mason', 'Anderson', 11, 'Guard', '4th', 'Northwest Elementary', 'Tracy Anderson', '(601) 555-1009', 'tracy.anderson@email.com'),
    ('Logan', 'Thomas', 24, 'Forward', '4th', 'Riverside Elementary', 'Kevin Thomas', '(601) 555-1010', 'kevin.thomas@email.com'),
    ('Lucas', 'Jackson', 13, 'Center', '4th', 'Northwest Elementary', 'Michelle Jackson', '(601) 555-1011', 'michelle.jackson@email.com'),
    ('Caleb', 'White', 9, 'Guard', '4th', 'Pine Valley Elementary', 'Steve White', '(601) 555-1012', 'steve.white@email.com'),
    ('Ryan', 'Harris', 17, 'Forward', '4th', 'Northwest Elementary', 'Laura Harris', '(601) 555-1013', 'laura.harris@email.com'),
    ('Isaiah', 'Martin', 6, 'Guard', '4th', 'Riverside Elementary', 'Carlos Martin', '(601) 555-1014', 'carlos.martin@email.com'),
    ('Aiden', 'Garcia', 21, 'Forward', '4th', 'Northwest Elementary', 'Maria Garcia', '(601) 555-1015', 'maria.garcia@email.com'),
    ('Carter', 'Rodriguez', 14, 'Center', '4th', 'Pine Valley Elementary', 'Juan Rodriguez', '(601) 555-1016', 'juan.rodriguez@email.com'),

    -- 5th Perry team (11 players)
    ('Bryce', 'Lewis', 4, 'Guard', '5th', 'Central Elementary', 'Patricia Lewis', '(601) 555-1017', 'pat.lewis@email.com'),
    ('Cole', 'Lee', 18, 'Forward', '5th', 'Eastside Elementary', 'Brian Lee', '(601) 555-1018', 'brian.lee@email.com'),
    ('Dylan', 'Walker', 25, 'Center', '5th', 'Central Elementary', 'Angela Walker', '(601) 555-1019', 'angela.walker@email.com'),
    ('Gavin', 'Hall', 16, 'Guard', '5th', 'Westfield Elementary', 'Mark Hall', '(601) 555-1020', 'mark.hall@email.com'),
    ('Hunter', 'Allen', 20, 'Forward', '5th', 'Central Elementary', 'Rebecca Allen', '(601) 555-1021', 'rebecca.allen@email.com'),
    ('Ian', 'Young', 3, 'Guard', '5th', 'Eastside Elementary', 'Christopher Young', '(601) 555-1022', 'chris.young@email.com'),
    ('Jaxon', 'Hernandez', 30, 'Forward', '5th', 'Central Elementary', 'Sandra Hernandez', '(601) 555-1023', 'sandra.hernandez@email.com'),
    ('Landon', 'King', 19, 'Center', '5th', 'Westfield Elementary', 'Timothy King', '(601) 555-1024', 'tim.king@email.com'),
    ('Nathan', 'Wright', 23, 'Guard', '5th', 'Central Elementary', 'Karen Wright', '(601) 555-1025', 'karen.wright@email.com'),
    ('Owen', 'Lopez', 1, 'Forward', '5th', 'Eastside Elementary', 'Daniel Lopez', '(601) 555-1026', 'daniel.lopez@email.com'),
    ('Parker', 'Hill', 32, 'Guard', '5th', 'Central Elementary', 'Nancy Hill', '(601) 555-1027', 'nancy.hill@email.com');

    -- Assign 4th Grixby/Evans players to team
    INSERT INTO public.player_teams (player_id, team_id, jersey_number, position)
    SELECT p.id, team_4th_grixby, p.jersey_number, p.position
    FROM public.players p
    WHERE p.first_name IN ('Mason', 'Logan', 'Lucas', 'Caleb', 'Ryan', 'Isaiah', 'Aiden', 'Carter')
    AND p.last_name IN ('Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Garcia', 'Rodriguez');

    -- Assign 5th Perry players to team
    INSERT INTO public.player_teams (player_id, team_id, jersey_number, position)
    SELECT p.id, team_5th_perry, p.jersey_number, p.position
    FROM public.players p
    WHERE p.first_name IN ('Bryce', 'Cole', 'Dylan', 'Gavin', 'Hunter', 'Ian', 'Jaxon', 'Landon', 'Nathan', 'Owen', 'Parker')
    AND p.last_name IN ('Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'Hernandez', 'King', 'Wright', 'Lopez', 'Hill');

    -- Insert sample practice schedules
    -- Express United 4th Foster - Mon/Wed at Monroe MS 6:00-7:30 PM
    INSERT INTO public.schedules (team_id, title, description, event_type, location, start_time, end_time, is_recurring, recurrence_pattern) VALUES
    (team_4th_foster, 'Monday Practice', 'Regular team practice', 'practice', 'Monroe Middle School Gym', '2024-09-23 18:00:00-05'::timestamptz, '2024-09-23 19:30:00-05'::timestamptz, true, 'weekly'),
    (team_4th_foster, 'Wednesday Practice', 'Regular team practice', 'practice', 'Monroe Middle School Gym', '2024-09-25 18:00:00-05'::timestamptz, '2024-09-25 19:30:00-05'::timestamptz, true, 'weekly'),

    -- Express United 4th Grixby/Evans - Tue/Thu at Northwest HS 6:00-8:00 PM
    (team_4th_grixby, 'Tuesday Practice', 'Regular team practice', 'practice', 'Northwest High School Gym', '2024-09-24 18:00:00-05'::timestamptz, '2024-09-24 20:00:00-05'::timestamptz, true, 'weekly'),
    (team_4th_grixby, 'Thursday Practice', 'Regular team practice', 'practice', 'Northwest High School Gym', '2024-09-26 18:00:00-05'::timestamptz, '2024-09-26 20:00:00-05'::timestamptz, true, 'weekly'),

    -- Express United 5th Perry - Tue/Thu at Northwest HS 6:00-8:00 PM
    (team_5th_perry, 'Tuesday Practice', 'Regular team practice', 'practice', 'Northwest High School Gym', '2024-09-24 18:00:00-05'::timestamptz, '2024-09-24 20:00:00-05'::timestamptz, true, 'weekly'),
    (team_5th_perry, 'Thursday Practice', 'Regular team practice', 'practice', 'Northwest High School Gym', '2024-09-26 18:00:00-05'::timestamptz, '2024-09-26 20:00:00-05'::timestamptz, true, 'weekly');

    -- Insert sample notifications
    INSERT INTO public.notifications (team_id, sender_id, title, message, notification_type) VALUES
    (team_4th_foster, coach_foster, 'Welcome to the Season!', 'Welcome to Express United 4th Foster! Practice starts this Monday at Monroe MS. Please arrive 15 minutes early.', 'general'),
    (team_4th_grixby, coach_grixby, 'Practice Schedule Update', 'Our Tuesday practice has been moved to the main gym at Northwest HS. See you there!', 'schedule'),
    (team_5th_perry, coach_perry, 'Team Photo Day', 'Team photos will be taken next Thursday before practice. Please have your players in uniform.', 'announcement');

    -- Insert some upcoming games
    INSERT INTO public.schedules (team_id, title, description, event_type, location, start_time, end_time, opponent, home_away) VALUES
    (team_4th_foster, 'vs Raiders', 'Season opener game', 'game', 'Monroe Middle School Gym', '2024-10-05 10:00:00-05'::timestamptz, '2024-10-05 11:30:00-05'::timestamptz, 'Monroe Raiders', 'home'),
    (team_4th_grixby, 'vs Eagles', 'Away game', 'game', 'Eastside Elementary Gym', '2024-10-06 11:00:00-05'::timestamptz, '2024-10-06 12:30:00-05'::timestamptz, 'Eastside Eagles', 'away'),
    (team_5th_perry, 'vs Lions', 'Home game', 'game', 'Northwest High School Gym', '2024-10-07 12:00:00-05'::timestamptz, '2024-10-07 13:30:00-05'::timestamptz, 'Central Lions', 'home');

    -- Add some medical/emergency info
    UPDATE public.players SET
        emergency_contact = 'Grandma Johnson',
        emergency_phone = '(601) 555-2001',
        medical_notes = 'Asthma - inhaler needed during practice'
    WHERE first_name = 'Jordan' AND last_name = 'Brown';

    UPDATE public.players SET
        emergency_contact = 'Uncle Williams',
        emergency_phone = '(601) 555-2002',
        medical_notes = 'Previous ankle injury - monitor closely'
    WHERE first_name = 'Cameron' AND last_name = 'Davis';

END $$;