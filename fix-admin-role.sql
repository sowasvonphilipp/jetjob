-- Give all current profiles the Admin role so Row Level Security allows updates
UPDATE profiles SET role = 'admin';
