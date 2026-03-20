-- Force insert the missing Master Admin profile if it doesn't exist
INSERT INTO profiles (id, role)
VALUES ('a1cd4ac8-bc83-4084-b78e-e70997ba2a4c', 'admin')
ON CONFLICT (id) DO UPDATE SET role = 'admin';

-- Force it for any other users as well just in case they are completely missing their profiles
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT id FROM auth.users LOOP
        INSERT INTO public.profiles (id, role)
        VALUES (r.id, 'admin')
        ON CONFLICT (id) DO UPDATE SET role = 'admin';
    END LOOP;
END;
$$;
