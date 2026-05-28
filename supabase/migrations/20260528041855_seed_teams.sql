-- =============================================================================
-- Seed: 48 selecciones del Mundial 2026
-- Orden: por grupo (A..L) y dentro del grupo en el orden del sorteo FIFA.
-- IDs: serial automático. Referencias desde matches (T-011) por `code`.
-- =============================================================================

insert into teams (name, code, group_letter, flag_emoji) values
  -- Grupo A
  ('México',              'MEX', 'A', '🇲🇽'),
  ('Sudáfrica',           'RSA', 'A', '🇿🇦'),
  ('Corea del Sur',       'KOR', 'A', '🇰🇷'),
  ('República Checa',     'CZE', 'A', '🇨🇿'),
  -- Grupo B
  ('Canadá',              'CAN', 'B', '🇨🇦'),
  ('Bosnia-Herzegovina',  'BIH', 'B', '🇧🇦'),
  ('Qatar',               'QAT', 'B', '🇶🇦'),
  ('Suiza',               'SUI', 'B', '🇨🇭'),
  -- Grupo C
  ('Brasil',              'BRA', 'C', '🇧🇷'),
  ('Marruecos',           'MAR', 'C', '🇲🇦'),
  ('Haití',               'HAI', 'C', '🇭🇹'),
  ('Escocia',             'SCO', 'C', '🏴󠁧󠁢󠁳󠁣󠁴󠁿'),
  -- Grupo D
  ('Estados Unidos',      'USA', 'D', '🇺🇸'),
  ('Paraguay',            'PAR', 'D', '🇵🇾'),
  ('Australia',           'AUS', 'D', '🇦🇺'),
  ('Turquía',             'TUR', 'D', '🇹🇷'),
  -- Grupo E
  ('Alemania',            'GER', 'E', '🇩🇪'),
  ('Curazao',             'CUW', 'E', '🇨🇼'),
  ('Costa de Marfil',     'CIV', 'E', '🇨🇮'),
  ('Ecuador',             'ECU', 'E', '🇪🇨'),
  -- Grupo F
  ('Países Bajos',        'NED', 'F', '🇳🇱'),
  ('Japón',               'JPN', 'F', '🇯🇵'),
  ('Suecia',              'SWE', 'F', '🇸🇪'),
  ('Túnez',               'TUN', 'F', '🇹🇳'),
  -- Grupo G
  ('Bélgica',             'BEL', 'G', '🇧🇪'),
  ('Egipto',              'EGY', 'G', '🇪🇬'),
  ('Irán',                'IRN', 'G', '🇮🇷'),
  ('Nueva Zelanda',       'NZL', 'G', '🇳🇿'),
  -- Grupo H
  ('España',              'ESP', 'H', '🇪🇸'),
  ('Cabo Verde',          'CPV', 'H', '🇨🇻'),
  ('Arabia Saudita',      'KSA', 'H', '🇸🇦'),
  ('Uruguay',             'URU', 'H', '🇺🇾'),
  -- Grupo I
  ('Francia',             'FRA', 'I', '🇫🇷'),
  ('Senegal',             'SEN', 'I', '🇸🇳'),
  ('Irak',                'IRQ', 'I', '🇮🇶'),
  ('Noruega',             'NOR', 'I', '🇳🇴'),
  -- Grupo J
  ('Argentina',           'ARG', 'J', '🇦🇷'),
  ('Argelia',             'ALG', 'J', '🇩🇿'),
  ('Austria',             'AUT', 'J', '🇦🇹'),
  ('Jordania',            'JOR', 'J', '🇯🇴'),
  -- Grupo K
  ('Portugal',            'POR', 'K', '🇵🇹'),
  ('RD Congo',            'COD', 'K', '🇨🇩'),
  ('Uzbekistán',          'UZB', 'K', '🇺🇿'),
  ('Colombia',            'COL', 'K', '🇨🇴'),
  -- Grupo L
  ('Inglaterra',          'ENG', 'L', '🏴󠁧󠁢󠁥󠁮󠁧󠁿'),
  ('Croacia',             'CRO', 'L', '🇭🇷'),
  ('Ghana',               'GHA', 'L', '🇬🇭'),
  ('Panamá',              'PAN', 'L', '🇵🇦');
