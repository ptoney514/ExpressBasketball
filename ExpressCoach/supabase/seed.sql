-- Seed data for Express United Basketball Teams
-- This file populates the database with all teams, coaches, and players

-- First, clear existing data (for development only)
TRUNCATE TABLE notifications CASCADE;
TRUNCATE TABLE player_teams CASCADE;
TRUNCATE TABLE coach_teams CASCADE;
TRUNCATE TABLE schedules CASCADE;
TRUNCATE TABLE players CASCADE;
TRUNCATE TABLE teams CASCADE;
TRUNCATE TABLE coaches CASCADE;
TRUNCATE TABLE clubs CASCADE;

-- Insert Express United club
INSERT INTO clubs (id, name, code, email, phone, website, created_at, updated_at)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'Express United Basketball', 'EXUNIT', 'info@expressunited.com', '555-0100', 'www.expressunited.com', NOW(), NOW());

-- Insert coaches
INSERT INTO coaches (id, club_id, first_name, last_name, email, phone, role, created_at, updated_at)
VALUES
  ('22222222-2222-2222-2222-222222222221', '11111111-1111-1111-1111-111111111111', 'Coach', 'Foster', 'foster@expressunited.com', '555-0101', 'coach', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Coach', 'Grixby', 'grixby@expressunited.com', '555-0102', 'coach', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222223', '11111111-1111-1111-1111-111111111111', 'Coach', 'Evans', 'evans@expressunited.com', '555-0103', 'assistant', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222224', '11111111-1111-1111-1111-111111111111', 'Coach', 'Perry', 'perry@expressunited.com', '555-0104', 'coach', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222225', '11111111-1111-1111-1111-111111111111', 'Coach', 'Todd', 'todd@expressunited.com', '555-0105', 'coach', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222226', '11111111-1111-1111-1111-111111111111', 'Coach', 'Scott', 'scott@expressunited.com', '555-0106', 'coach', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222227', '11111111-1111-1111-1111-111111111111', 'Coach', 'Mitchell', 'mitchell@expressunited.com', '555-0107', 'coach', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222228', '11111111-1111-1111-1111-111111111111', 'Director', 'Admin', 'director@expressunited.com', '555-0100', 'director', NOW(), NOW());

-- Insert teams with their practice schedules
INSERT INTO teams (id, club_id, name, age_group, season, team_code, practice_location, practice_schedule, team_color, created_at, updated_at)
VALUES
  -- 4th Grade Teams
  ('33333333-3333-3333-3333-333333333331', '11111111-1111-1111-1111-111111111111', 'Express United 4th - Foster', '4th Grade', 'Fall/Winter 2025', 'EU4FOS', 'Monroe MS', 'Mon/Wed 6:00-7:30 PM', 'Orange', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333332', '11111111-1111-1111-1111-111111111111', 'Express United 4th - Grixby/Evans', '4th Grade', 'Fall/Winter 2025', 'EU4GRE', 'Northwest HS', 'Tue/Thu 6:00-8:00 PM', 'Orange', NOW(), NOW()),

  -- 5th Grade Team
  ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Express United 5th - Perry', '5th Grade', 'Fall/Winter 2025', 'EU5PER', 'Northwest HS', 'Tue/Thu 6:00-8:00 PM', 'Orange', NOW(), NOW()),

  -- 6th Grade Teams
  ('33333333-3333-3333-3333-333333333334', '11111111-1111-1111-1111-111111111111', 'Express United 6th - Todd', '6th Grade', 'Fall/Winter 2025', 'EU6TOD', 'McMillan MS / Monroe MS', 'Tue 6:00-7:30 PM (McMillan), Thu 6:00-7:30 PM (Monroe)', 'Orange', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333335', '11111111-1111-1111-1111-111111111111', 'Express United 6th - Scott', '6th Grade', 'Fall/Winter 2025', 'EU6SCO', 'McMillan MS / Central HS', 'Tue 6:00-7:30 PM (McMillan), Wed 6:00-7:30 PM (Central)', 'Orange', NOW(), NOW()),

  -- 7th Grade Teams
  ('33333333-3333-3333-3333-333333333336', '11111111-1111-1111-1111-111111111111', 'Express United 7th', '7th Grade', 'Fall/Winter 2025', 'EU7MAI', 'Central HS', 'Mon/Wed 6:00-8:00 PM', 'Orange', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333337', '11111111-1111-1111-1111-111111111111', 'Express United 7th - Mitchell', '7th Grade', 'Fall/Winter 2025', 'EU7MIT', 'Central HS', 'Mon/Wed 6:00-8:00 PM', 'Orange', NOW(), NOW()),

  -- 8th Grade Teams
  ('33333333-3333-3333-3333-333333333338', '11111111-1111-1111-1111-111111111111', 'Express United 8th', '8th Grade', 'Fall/Winter 2025', 'EU8MAI', 'Central HS', 'Mon/Wed 6:00-8:00 PM', 'Orange', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333339', '11111111-1111-1111-1111-111111111111', 'Express United 8th - Mitchell', '8th Grade', 'Fall/Winter 2025', 'EU8MIT', 'Central HS', 'Mon/Wed 6:00-8:00 PM', 'Orange', NOW(), NOW());

-- Link coaches to teams (including co-coaches)
INSERT INTO coach_teams (coach_id, team_id, role)
VALUES
  ('22222222-2222-2222-2222-222222222221', '33333333-3333-3333-3333-333333333331', 'head_coach'), -- Foster -> 4th Foster
  ('22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333332', 'head_coach'), -- Grixby -> 4th Grixby/Evans
  ('22222222-2222-2222-2222-222222222223', '33333333-3333-3333-3333-333333333332', 'assistant_coach'), -- Evans -> 4th Grixby/Evans
  ('22222222-2222-2222-2222-222222222224', '33333333-3333-3333-3333-333333333333', 'head_coach'), -- Perry -> 5th Perry
  ('22222222-2222-2222-2222-222222222225', '33333333-3333-3333-3333-333333333334', 'head_coach'), -- Todd -> 6th Todd
  ('22222222-2222-2222-2222-222222222226', '33333333-3333-3333-3333-333333333335', 'head_coach'), -- Scott -> 6th Scott
  ('22222222-2222-2222-2222-222222222221', '33333333-3333-3333-3333-333333333336', 'head_coach'), -- Foster -> 7th Main (dual role)
  ('22222222-2222-2222-2222-222222222227', '33333333-3333-3333-3333-333333333337', 'head_coach'), -- Mitchell -> 7th Mitchell
  ('22222222-2222-2222-2222-222222222221', '33333333-3333-3333-3333-333333333338', 'head_coach'), -- Foster -> 8th Main (dual role)
  ('22222222-2222-2222-2222-222222222227', '33333333-3333-3333-3333-333333333339', 'head_coach'); -- Mitchell -> 8th Mitchell

-- Insert all players with correct schema
-- 4th Grade Foster Team
INSERT INTO players (first_name, last_name, jersey_number, position, grade_level, school, parent_name, parent_phone, parent_email, emergency_contact, emergency_phone, created_at, updated_at)
VALUES
  ('Isaiah', 'Criswell', 1, 'Guard', '4th', 'Monroe MS', 'Parent Criswell', '555-1001', 'criswell@email.com', 'Emergency Contact', '555-9001', NOW(), NOW()),
  ('Merrick', 'Pringle', 2, 'Forward', '4th', 'Monroe MS', 'Parent Pringle', '555-1002', 'pringle@email.com', 'Emergency Contact', '555-9002', NOW(), NOW()),
  ('Declan', 'Jimenez-Creegan', 3, 'Guard', '4th', 'Monroe MS', 'Parent Jimenez', '555-1003', 'jimenez@email.com', 'Emergency Contact', '555-9003', NOW(), NOW()),
  ('Callan', 'Kapels', 4, 'Center', '4th', 'Monroe MS', 'Parent Kapels', '555-1004', 'kapels@email.com', 'Emergency Contact', '555-9004', NOW(), NOW()),
  ('Zion', 'Gibbs', 5, 'Forward', '4th', 'Monroe MS', 'Parent Gibbs', '555-1005', 'gibbs@email.com', 'Emergency Contact', '555-9005', NOW(), NOW()),
  ('Cain', 'Hicks', 6, 'Guard', '4th', 'Monroe MS', 'Parent Hicks', '555-1006', 'hicks@email.com', 'Emergency Contact', '555-9006', NOW(), NOW()),
  ('Ka''Mari', 'Douglas', 7, 'Forward', '4th', 'Monroe MS', 'Parent Douglas', '555-1007', 'douglas@email.com', 'Emergency Contact', '555-9007', NOW(), NOW()),

-- 4th Grade Grixby/Evans Team
  ('Javi', 'Shaw', 10, 'Guard', '4th', 'Northwest HS', 'Parent Shaw', '555-1010', 'shaw@email.com', 'Emergency Contact', '555-9010', NOW(), NOW()),
  ('Carlos', 'Gonzalous', 11, 'Forward', '4th', 'Northwest HS', 'Parent Gonzalous', '555-1011', 'gonzalous@email.com', 'Emergency Contact', '555-9011', NOW(), NOW()),
  ('Yohan', 'Grixby', 12, 'Guard', '4th', 'Northwest HS', 'Parent Grixby', '555-1012', 'grixby@email.com', 'Emergency Contact', '555-9012', NOW(), NOW()),
  ('Layland', 'Smith', 13, 'Center', '4th', 'Northwest HS', 'Parent Smith', '555-1013', 'smith@email.com', 'Emergency Contact', '555-9013', NOW(), NOW()),
  ('Jackson', 'Boyd', 14, 'Forward', '4th', 'Northwest HS', 'Parent Boyd', '555-1014', 'boyd@email.com', 'Emergency Contact', '555-9014', NOW(), NOW()),
  ('Landon', 'Boyd', 15, 'Guard', '4th', 'Northwest HS', 'Parent Boyd', '555-1014', 'boyd@email.com', 'Emergency Contact', '555-9014', NOW(), NOW()),
  ('Aaron', 'Evans', 16, 'Forward', '4th', 'Northwest HS', 'Parent Evans', '555-1016', 'evans@email.com', 'Emergency Contact', '555-9016', NOW(), NOW()),
  ('Axel', 'Zuck', 17, 'Center', '4th', 'Northwest HS', 'Parent Zuck', '555-1017', 'zuck@email.com', 'Emergency Contact', '555-9017', NOW(), NOW()),

-- 5th Grade Perry Team (11 players)
  ('Javari', 'Stramel', 20, 'Guard', '5th', 'Northwest HS', 'Parent Stramel', '555-1020', 'stramel@email.com', 'Emergency Contact', '555-9020', NOW(), NOW()),
  ('Kadon', 'Simms', 21, 'Forward', '5th', 'Northwest HS', 'Parent Simms', '555-1021', 'simms@email.com', 'Emergency Contact', '555-9021', NOW(), NOW()),
  ('J''Sieon', 'Jilg-Brown', 22, 'Guard', '5th', 'Northwest HS', 'Parent Jilg-Brown', '555-1022', 'jilgbrown@email.com', 'Emergency Contact', '555-9022', NOW(), NOW()),
  ('Beckett', 'Parker', 23, 'Center', '5th', 'Northwest HS', 'Parent Parker', '555-1023', 'parker@email.com', 'Emergency Contact', '555-9023', NOW(), NOW()),
  ('Tucker', 'Adams', 24, 'Forward', '5th', 'Northwest HS', 'Parent Adams', '555-1024', 'adams@email.com', 'Emergency Contact', '555-9024', NOW(), NOW()),
  ('Kenyon', 'Jackson', 25, 'Guard', '5th', 'Northwest HS', 'Parent Jackson', '555-1025', 'jackson@email.com', 'Emergency Contact', '555-9025', NOW(), NOW()),
  ('Kordai', 'Douglas', 26, 'Forward', '5th', 'Northwest HS', 'Parent Douglas', '555-1026', 'douglas2@email.com', 'Emergency Contact', '555-9026', NOW(), NOW()),
  ('Charlie', 'Nelson', 27, 'Center', '5th', 'Northwest HS', 'Parent Nelson', '555-1027', 'nelson@email.com', 'Emergency Contact', '555-9027', NOW(), NOW()),
  ('Chrishon', 'Bailey', 28, 'Guard', '5th', 'Northwest HS', 'Parent Bailey', '555-1028', 'bailey@email.com', 'Emergency Contact', '555-9028', NOW(), NOW()),
  ('Karmine', 'Scott', 29, 'Forward', '5th', 'Northwest HS', 'Parent Scott', '555-1029', 'scott@email.com', 'Emergency Contact', '555-9029', NOW(), NOW()),
  ('Anthony', 'McNair', 30, 'Guard', '5th', 'Northwest HS', 'Parent McNair', '555-1030', 'mcnair@email.com', 'Emergency Contact', '555-9030', NOW(), NOW()),

-- 6th Grade Todd Team
  ('LJ', 'Gaines', 31, 'Guard', '6th', 'McMillan MS', 'Parent Gaines', '555-1031', 'gaines@email.com', 'Emergency Contact', '555-9031', NOW(), NOW()),
  ('Zion', 'Hoskins', 32, 'Forward', '6th', 'McMillan MS', 'Parent Hoskins', '555-1032', 'hoskins@email.com', 'Emergency Contact', '555-9032', NOW(), NOW()),
  ('Charlie', 'Kneifl', 33, 'Guard', '6th', 'McMillan MS', 'Parent Kneifl', '555-1033', 'kneifl@email.com', 'Emergency Contact', '555-9033', NOW(), NOW()),
  ('Thomas', 'Nelson', 34, 'Center', '6th', 'McMillan MS', 'Parent Nelson', '555-1034', 'nelson2@email.com', 'Emergency Contact', '555-9034', NOW(), NOW()),
  ('Carter', 'Matthias', 35, 'Forward', '6th', 'McMillan MS', 'Parent Matthias', '555-1035', 'matthias@email.com', 'Emergency Contact', '555-9035', NOW(), NOW()),
  ('Terrell', 'Knox', 36, 'Guard', '6th', 'McMillan MS', 'Parent Knox', '555-1036', 'knox@email.com', 'Emergency Contact', '555-9036', NOW(), NOW()),
  ('Matthew', 'Amalek', 37, 'Forward', '6th', 'McMillan MS', 'Parent Amalek', '555-1037', 'amalek@email.com', 'Emergency Contact', '555-9037', NOW(), NOW()),
  ('Kevin', 'Peak', 38, 'Center', '6th', 'McMillan MS', 'Parent Peak', '555-1038', 'peak@email.com', 'Emergency Contact', '555-9038', NOW(), NOW()),
  ('Kei''Von', 'Lewis', 39, 'Guard', '6th', 'McMillan MS', 'Parent Lewis', '555-1039', 'lewis@email.com', 'Emergency Contact', '555-9039', NOW(), NOW()),
  ('Zyaire', 'Brown', 40, 'Forward', '6th', 'McMillan MS', 'Parent Brown', '555-1040', 'brown@email.com', 'Emergency Contact', '555-9040', NOW(), NOW()),

-- 6th Grade Scott Team
  ('Zy''Aire', 'Rogers', 41, 'Guard', '6th', 'McMillan MS', 'Parent Rogers', '555-1041', 'rogers@email.com', 'Emergency Contact', '555-9041', NOW(), NOW()),
  ('Haskell', 'Lee', 42, 'Forward', '6th', 'McMillan MS', 'Parent Lee', '555-1042', 'lee@email.com', 'Emergency Contact', '555-9042', NOW(), NOW()),
  ('A''Sire', 'Brown', 43, 'Guard', '6th', 'McMillan MS', 'Parent Brown', '555-1043', 'brown2@email.com', 'Emergency Contact', '555-9043', NOW(), NOW()),
  ('Kavon', 'Williams', 44, 'Center', '6th', 'McMillan MS', 'Parent Williams', '555-1044', 'williams@email.com', 'Emergency Contact', '555-9044', NOW(), NOW()),
  ('MJ', 'Williams', 45, 'Forward', '6th', 'McMillan MS', 'Parent Williams', '555-1045', 'williams2@email.com', 'Emergency Contact', '555-9045', NOW(), NOW()),
  ('David', 'Brown', 46, 'Guard', '6th', 'McMillan MS', 'Parent Brown', '555-1046', 'brown3@email.com', 'Emergency Contact', '555-9046', NOW(), NOW()),
  ('Jordan', 'Wubbels', 47, 'Forward', '6th', 'McMillan MS', 'Parent Wubbels', '555-1047', 'wubbels@email.com', 'Emergency Contact', '555-9047', NOW(), NOW()),
  ('Jakaien', 'Stramel', 48, 'Center', '6th', 'McMillan MS', 'Parent Stramel', '555-1048', 'stramel2@email.com', 'Emergency Contact', '555-9048', NOW(), NOW()),
  ('Giorgio', 'Houston Jr', 49, 'Guard', '6th', 'McMillan MS', 'Parent Houston', '555-1049', 'houston@email.com', 'Emergency Contact', '555-9049', NOW(), NOW()),

-- 7th Grade Main Team
  ('Layton', 'Smith', 50, 'Guard', '7th', 'Central HS', 'Parent Smith', '555-1050', 'smith3@email.com', 'Emergency Contact', '555-9050', NOW(), NOW()),
  ('Schuyler', 'Say', 51, 'Forward', '7th', 'Central HS', 'Parent Say', '555-1051', 'say@email.com', 'Emergency Contact', '555-9051', NOW(), NOW()),
  ('Tre', 'Kuhn', 52, 'Guard', '7th', 'Central HS', 'Parent Kuhn', '555-1052', 'kuhn@email.com', 'Emergency Contact', '555-9052', NOW(), NOW()),
  ('Carter', 'Davis', 53, 'Center', '7th', 'Central HS', 'Parent Davis', '555-1053', 'davis@email.com', 'Emergency Contact', '555-9053', NOW(), NOW()),
  ('Henry', 'Kittell', 54, 'Forward', '7th', 'Central HS', 'Parent Kittell', '555-1054', 'kittell@email.com', 'Emergency Contact', '555-9054', NOW(), NOW()),
  ('TJ', 'Wright', 55, 'Guard', '7th', 'Central HS', 'Parent Wright', '555-1055', 'wright@email.com', 'Emergency Contact', '555-9055', NOW(), NOW()),
  ('Jacen', 'Davis', 56, 'Forward', '7th', 'Central HS', 'Parent Davis', '555-1056', 'davis2@email.com', 'Emergency Contact', '555-9056', NOW(), NOW()),

-- 7th Grade Mitchell Team
  ('Kai', 'Mitchell', 60, 'Guard', '7th', 'Central HS', 'Parent Mitchell', '555-1060', 'mitchell@email.com', 'Emergency Contact', '555-9060', NOW(), NOW()),
  ('DJ', 'Tate', 61, 'Forward', '7th', 'Central HS', 'Parent Tate', '555-1061', 'tate@email.com', 'Emergency Contact', '555-9061', NOW(), NOW()),
  ('Treason', 'Adams', 62, 'Guard', '7th', 'Central HS', 'Parent Adams', '555-1062', 'adams2@email.com', 'Emergency Contact', '555-9062', NOW(), NOW()),
  ('Blake', 'Wojtalewicz', 64, 'Center', '7th', 'Central HS', 'Parent Wojtalewicz', '555-1064', 'wojtalewicz@email.com', 'Emergency Contact', '555-9064', NOW(), NOW()),
  ('Ray', 'Perry', 65, 'Forward', '7th', 'Central HS', 'Parent Perry', '555-1065', 'perry2@email.com', 'Emergency Contact', '555-9065', NOW(), NOW()),
  ('Monroe', 'Love', 66, 'Guard', '7th', 'Central HS', 'Parent Love', '555-1066', 'love@email.com', 'Emergency Contact', '555-9066', NOW(), NOW()),

-- 8th Grade Main Team
  ('Dupree', 'Davis', 70, 'Guard', '8th', 'Central HS', 'Parent Davis', '555-1070', 'davis3@email.com', 'Emergency Contact', '555-9070', NOW(), NOW()),
  ('Jay', 'Garrison', 71, 'Forward', '8th', 'Central HS', 'Parent Garrison', '555-1071', 'garrison@email.com', 'Emergency Contact', '555-9071', NOW(), NOW()),
  ('Sean', 'Jackson', 72, 'Guard', '8th', 'Central HS', 'Parent Jackson', '555-1072', 'jackson2@email.com', 'Emergency Contact', '555-9072', NOW(), NOW()),
  ('Titus', 'Adams', 73, 'Center', '8th', 'Central HS', 'Parent Adams', '555-1073', 'adams3@email.com', 'Emergency Contact', '555-9073', NOW(), NOW()),
  ('Xander', 'Heyen', 74, 'Forward', '8th', 'Central HS', 'Parent Heyen', '555-1074', 'heyen@email.com', 'Emergency Contact', '555-9074', NOW(), NOW()),
  ('Tyler', 'Rankins', 75, 'Guard', '8th', 'Central HS', 'Parent Rankins', '555-1075', 'rankins@email.com', 'Emergency Contact', '555-9075', NOW(), NOW()),
  ('Jamison', 'Pitzl', 76, 'Forward', '8th', 'Central HS', 'Parent Pitzl', '555-1076', 'pitzl@email.com', 'Emergency Contact', '555-9076', NOW(), NOW()),
  ('Carmelo', 'Plunkent', 77, 'Center', '8th', 'Central HS', 'Parent Plunkent', '555-1077', 'plunkent@email.com', 'Emergency Contact', '555-9077', NOW(), NOW()),
  ('Brighton', 'Clark', 78, 'Guard', '8th', 'Central HS', 'Parent Clark', '555-1078', 'clark@email.com', 'Emergency Contact', '555-9078', NOW(), NOW()),
  ('Joshua', 'Cannon', 79, 'Forward', '8th', 'Central HS', 'Parent Cannon', '555-1079', 'cannon@email.com', 'Emergency Contact', '555-9079', NOW(), NOW()),

-- 8th Grade Mitchell Team
  ('Rakim', 'Frampton', 80, 'Guard', '8th', 'Central HS', 'Parent Frampton', '555-1080', 'frampton@email.com', 'Emergency Contact', '555-9080', NOW(), NOW()),
  ('Samajai', 'Critten', 81, 'Forward', '8th', 'Central HS', 'Parent Critten', '555-1081', 'critten@email.com', 'Emergency Contact', '555-9081', NOW(), NOW()),
  ('Avery', 'Tyler', 82, 'Guard', '8th', 'Central HS', 'Parent Tyler', '555-1082', 'tyler@email.com', 'Emergency Contact', '555-9082', NOW(), NOW()),
  ('Atiyyah', 'Sandlin-EL', 83, 'Center', '8th', 'Central HS', 'Parent Sandlin', '555-1083', 'sandlin@email.com', 'Emergency Contact', '555-9083', NOW(), NOW()),
  ('AJ', 'Tanner', 84, 'Forward', '8th', 'Central HS', 'Parent Tanner', '555-1084', 'tanner@email.com', 'Emergency Contact', '555-9084', NOW(), NOW()),
  ('Jalen', 'Falkner', 85, 'Guard', '8th', 'Central HS', 'Parent Falkner', '555-1085', 'falkner@email.com', 'Emergency Contact', '555-9085', NOW(), NOW()),
  ('Chris', 'Bailey', 86, 'Forward', '8th', 'Central HS', 'Parent Bailey', '555-1086', 'bailey2@email.com', 'Emergency Contact', '555-9086', NOW(), NOW());

-- Now link players to teams using a more efficient method
-- 4th Foster Team
INSERT INTO player_teams (player_id, team_id)
SELECT id, '33333333-3333-3333-3333-333333333331'
FROM players
WHERE last_name IN ('Criswell', 'Pringle', 'Jimenez-Creegan', 'Kapels', 'Gibbs', 'Hicks')
   OR (last_name = 'Douglas' AND first_name = 'Ka''Mari');

-- 4th Grixby/Evans Team
INSERT INTO player_teams (player_id, team_id)
SELECT id, '33333333-3333-3333-3333-333333333332'
FROM players
WHERE last_name IN ('Shaw', 'Gonzalous', 'Grixby', 'Zuck')
   OR (last_name = 'Smith' AND first_name = 'Layland')
   OR (last_name = 'Boyd' AND first_name IN ('Jackson', 'Landon'))
   OR (last_name = 'Evans' AND first_name = 'Aaron');

-- 5th Perry Team
INSERT INTO player_teams (player_id, team_id)
SELECT id, '33333333-3333-3333-3333-333333333333'
FROM players
WHERE (last_name = 'Stramel' AND first_name = 'Javari')
   OR last_name IN ('Simms', 'Jilg-Brown', 'Parker', 'Bailey', 'McNair')
   OR (last_name = 'Adams' AND first_name = 'Tucker')
   OR (last_name = 'Jackson' AND first_name = 'Kenyon')
   OR (last_name = 'Douglas' AND first_name = 'Kordai')
   OR (last_name = 'Nelson' AND first_name = 'Charlie' AND jersey_number = 27)
   OR (last_name = 'Scott' AND first_name = 'Karmine');

-- 6th Todd Team
INSERT INTO player_teams (player_id, team_id)
SELECT id, '33333333-3333-3333-3333-333333333334'
FROM players
WHERE last_name IN ('Gaines', 'Hoskins', 'Kneifl', 'Matthias', 'Knox', 'Amalek', 'Peak')
   OR (last_name = 'Nelson' AND first_name = 'Thomas')
   OR (last_name = 'Lewis' AND first_name = 'Kei''Von')
   OR (last_name = 'Brown' AND first_name = 'Zyaire');

-- 6th Scott Team
INSERT INTO player_teams (player_id, team_id)
SELECT id, '33333333-3333-3333-3333-333333333335'
FROM players
WHERE last_name IN ('Rogers', 'Lee', 'Wubbels', 'Houston Jr')
   OR (last_name = 'Brown' AND first_name IN ('A''Sire', 'David'))
   OR (last_name = 'Williams' AND first_name IN ('Kavon', 'MJ'))
   OR (last_name = 'Stramel' AND first_name = 'Jakaien');

-- 7th Main Team
INSERT INTO player_teams (player_id, team_id)
SELECT id, '33333333-3333-3333-3333-333333333336'
FROM players
WHERE (last_name = 'Smith' AND first_name = 'Layton')
   OR last_name IN ('Say', 'Kuhn', 'Kittell', 'Wright')
   OR (last_name = 'Davis' AND first_name IN ('Carter', 'Jacen'));

-- 7th Mitchell Team (Jacen Davis plays on both)
INSERT INTO player_teams (player_id, team_id)
SELECT id, '33333333-3333-3333-3333-333333333337'
FROM players
WHERE (last_name = 'Mitchell' AND first_name = 'Kai')
   OR last_name IN ('Tate', 'Wojtalewicz', 'Love')
   OR (last_name = 'Adams' AND first_name = 'Treason')
   OR (last_name = 'Perry' AND first_name = 'Ray')
   OR (last_name = 'Davis' AND first_name = 'Jacen'); -- Plays on both teams

-- 8th Main Team
INSERT INTO player_teams (player_id, team_id)
SELECT id, '33333333-3333-3333-3333-333333333338'
FROM players
WHERE (last_name = 'Davis' AND first_name = 'Dupree')
   OR last_name IN ('Garrison', 'Heyen', 'Rankins', 'Pitzl', 'Plunkent', 'Clark', 'Cannon')
   OR (last_name = 'Jackson' AND first_name = 'Sean')
   OR (last_name = 'Adams' AND first_name = 'Titus'); -- Plays on both teams

-- 8th Mitchell Team (Titus Adams plays on both)
INSERT INTO player_teams (player_id, team_id)
SELECT id, '33333333-3333-3333-3333-333333333339'
FROM players
WHERE last_name IN ('Frampton', 'Critten', 'Tyler', 'Sandlin-EL', 'Tanner', 'Falkner')
   OR (last_name = 'Bailey' AND first_name = 'Chris')
   OR (last_name = 'Adams' AND first_name = 'Titus'); -- Plays on both teams

-- Add some sample practice schedules for the next week
INSERT INTO schedules (team_id, title, event_type, location, start_time, end_time, description, created_at, updated_at)
VALUES
  -- Monday practices
  ('33333333-3333-3333-3333-333333333331', 'Team Practice', 'practice', 'Monroe MS', CURRENT_DATE + TIME '18:00', CURRENT_DATE + TIME '19:30', 'Regular Monday practice', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333336', 'Team Practice', 'practice', 'Central HS', CURRENT_DATE + TIME '18:00', CURRENT_DATE + TIME '20:00', 'Regular Monday practice', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333337', 'Team Practice', 'practice', 'Central HS', CURRENT_DATE + TIME '18:00', CURRENT_DATE + TIME '20:00', 'Regular Monday practice', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333338', 'Team Practice', 'practice', 'Central HS', CURRENT_DATE + TIME '18:00', CURRENT_DATE + TIME '20:00', 'Regular Monday practice', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333339', 'Team Practice', 'practice', 'Central HS', CURRENT_DATE + TIME '18:00', CURRENT_DATE + TIME '20:00', 'Regular Monday practice', NOW(), NOW()),

  -- Sample Saturday games
  ('33333333-3333-3333-3333-333333333331', 'vs. Omaha Thunder', 'game', 'Monroe MS', CURRENT_DATE + INTERVAL '5 days' + TIME '10:00', CURRENT_DATE + INTERVAL '5 days' + TIME '11:30', 'Home game', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333333', 'vs. Lincoln Lightning', 'game', 'Northwest HS', CURRENT_DATE + INTERVAL '5 days' + TIME '12:00', CURRENT_DATE + INTERVAL '5 days' + TIME '13:30', 'Home game', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333338', 'vs. Bellevue Storm', 'game', 'Central HS', CURRENT_DATE + INTERVAL '5 days' + TIME '14:00', CURRENT_DATE + INTERVAL '5 days' + TIME '15:30', 'Home game', NOW(), NOW());

-- Add a welcome announcement for each team
INSERT INTO notifications (team_id, sender_id, title, message, notification_type, target_audience, sent_at, created_at)
SELECT
  id,
  '22222222-2222-2222-2222-222222222228', -- Director ID
  'Welcome to Express United Basketball!',
  'Welcome to the ' || name || '! We''re excited for a great season. Please check the schedule for practice times and locations.',
  'general',
  'all',
  NOW(),
  NOW()
FROM teams;

-- Verify the data was inserted
SELECT 'Teams created:' as info, COUNT(*) as count FROM teams
UNION ALL
SELECT 'Coaches created:', COUNT(*) FROM coaches
UNION ALL
SELECT 'Players created:', COUNT(*) FROM players
UNION ALL
SELECT 'Player-Team assignments:', COUNT(*) FROM player_teams
UNION ALL
SELECT 'Coach-Team assignments:', COUNT(*) FROM coach_teams
UNION ALL
SELECT 'Schedules created:', COUNT(*) FROM schedules
UNION ALL
SELECT 'Notifications created:', COUNT(*) FROM notifications;