BEGIN;

-- 2. Create a dedicated schema for OSM
CREATE SCHEMA osm;

-- 4. Set the search path so Osmosis finds the right schema
-- (Note: Osmosis usually writes to the 'public' schema by default. 
-- To force it into the 'osm' schema, we set the user's default path)
ALTER USER :"db_user" SET search_path TO osm, public;

COMMIT;