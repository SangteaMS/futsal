CREATE DATABASE IF NOT EXISTS futsal_finder
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE futsal_finder;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  password VARCHAR(120) NOT NULL,
  role ENUM('ORGANIZER', 'PLAYER') NOT NULL
);

CREATE TABLE IF NOT EXISTS grounds (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL UNIQUE,
  area VARCHAR(100) NOT NULL,
  surface VARCHAR(80) NOT NULL,
  capacity INT NOT NULL
);

CREATE TABLE IF NOT EXISTS bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ground_id INT NOT NULL,
  organizer_id INT NOT NULL,
  match_date DATE NOT NULL,
  slot VARCHAR(40) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_ground_slot UNIQUE (ground_id, match_date, slot),
  FOREIGN KEY (ground_id) REFERENCES grounds(id),
  FOREIGN KEY (organizer_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS matches (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id INT NOT NULL UNIQUE,
  organizer_id INT NOT NULL,
  title VARCHAR(100) NOT NULL,
  additional_players_needed INT NOT NULL,
  status ENUM('OPEN', 'FULL') NOT NULL DEFAULT 'OPEN',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (booking_id) REFERENCES bookings(id),
  FOREIGN KEY (organizer_id) REFERENCES users(id),
  CHECK (additional_players_needed BETWEEN 1 AND 30)
);

CREATE TABLE IF NOT EXISTS join_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  match_id INT NOT NULL,
  player_id INT NOT NULL,
  status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
  requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_player_match UNIQUE (match_id, player_id),
  FOREIGN KEY (match_id) REFERENCES matches(id),
  FOREIGN KEY (player_id) REFERENCES users(id)
);

INSERT IGNORE INTO users (name, email, password, role) VALUES
  ('Aarav Organizer', 'organizer@futsal.demo', 'demo123', 'ORGANIZER'),
  ('Maya Player', 'player@futsal.demo', 'demo123', 'PLAYER');

INSERT IGNORE INTO grounds (name, area, surface, capacity) VALUES
  ('Greenline Arena', 'Koramangala', 'FIFA-grade turf', 10),
  ('The Futsal Yard', 'Indiranagar', 'Premium artificial turf', 12),
  ('Eastside Sports Hub', 'Whitefield', 'Indoor synthetic turf', 10);

INSERT IGNORE INTO bookings (ground_id, organizer_id, match_date, slot)
SELECT g.id, u.id, CURRENT_DATE + INTERVAL 3 DAY, '07:00 PM – 08:00 PM'
FROM grounds g JOIN users u ON u.email = 'organizer@futsal.demo'
WHERE g.name = 'Greenline Arena';

INSERT IGNORE INTO bookings (ground_id, organizer_id, match_date, slot)
SELECT g.id, u.id, CURRENT_DATE + INTERVAL 5 DAY, '08:00 PM – 09:00 PM'
FROM grounds g JOIN users u ON u.email = 'organizer@futsal.demo'
WHERE g.name = 'The Futsal Yard';

INSERT IGNORE INTO matches (booking_id, organizer_id, title, additional_players_needed)
SELECT b.id, u.id, 'Friday Night Five-a-side', 4
FROM bookings b
JOIN grounds g ON g.id = b.ground_id
JOIN users u ON u.id = b.organizer_id
WHERE g.name = 'Greenline Arena'
  AND u.email = 'organizer@futsal.demo'
  AND b.match_date = CURRENT_DATE + INTERVAL 3 DAY
  AND b.slot = '07:00 PM – 08:00 PM';

INSERT IGNORE INTO matches (booking_id, organizer_id, title, additional_players_needed)
SELECT b.id, u.id, 'Sunday Evening Futsal', 3
FROM bookings b
JOIN grounds g ON g.id = b.ground_id
JOIN users u ON u.id = b.organizer_id
WHERE g.name = 'The Futsal Yard'
  AND u.email = 'organizer@futsal.demo'
  AND b.match_date = CURRENT_DATE + INTERVAL 5 DAY
  AND b.slot = '08:00 PM – 09:00 PM';
