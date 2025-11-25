-- ================================================================
-- Link study area forest polygons with protected area status
-- ================================================================
-- 2025-01-31
-- Peter R.
-- PhD Thesis, Chapter 3
-- The aim of the code is to figure out what forest polygons are within protected areas. By forest I mean background forest derived from Canada (NTEMS) landcover maps
-- This seemed to be a simple task but it not given that you need three queries: st_intersection, st_difference, and not intersection
-- A protected area polygon can split a stamp polygon and in doing so part of the later could be protected and the other part non protected
-- Perhaps I should have gone done the raster route instead of polygons
-- I created this script with the help of ChatGPT. 
-- For some reason, the easiest query (not intersect) took the longest
-- At the end of this script there is code to create the VIEWS that combines the tables together
-- The forest land cover layer used below was imported with psql using a sql file genreated in QGIS
-- Note that EPSG 3978 (Canada atlas) is used here as this is the orginal projects of the land cover raster
-- NOte: this is the old version which was not right as it created the cros product.

-- Prep the forest cover layer
-- Index not need as sql created index duirng importing
ALTER TABLE forest_lcover_2003_v1 ADD COLUMN class varchar(30);
UPDATE forest_lcover_2003_v1 set class='forest';
	
-- Loop 1
-- Create forest tables that intersect with protected areas

DO $$ 
DECLARE 
    i INT;
    new_tbl_name TEXT;
    join_tbl_name TEXT;
	index_name TEXT;
	--year_labels TEXT[] := ARRAY['Change 1 (period 1 vs. period 2)', 'Change 2 (period 2 vs. period 3)', 'Change 3 (period 3 vs. period 4)']; -- Labels for table comments
	table_comment TEXT;
BEGIN
    FOR i IN 1..1 LOOP
        new_tbl_name := 'forest_lcover_2003_int_v1';  -- New table to be created (e.g., new_table_1, new_table_2)
        join_tbl_name := 'forest_lcover_2003_v1';     -- Table to join (e.g., table_1, table_2)
		index_name := 'forest_lcover_2003_int_v1_geom_idx'; -- New index name
		table_comment := 'Study area forest that intersect with protected areas. [2025-01-31]';
		

-- Step 1: Create the new table with all data except the primary key	
        EXECUTE format('
	   
CREATE TABLE %I AS
SELECT t1.ogc_fid, t1.fid, t1.layer, t1.class, t2.status, St_Multi((ST_DUMP(st_intersection(t1.geom, t2.geom))).geom)::geometry(MultiPolygon,3978) AS geom
FROM
%I t1
LEFT JOIN -- This is safer with a JOIN
(SELECT gid, __gid as gid0, 1 AS status, st_transform(geom, 3978) geom FROM cpcad_dec2020_clipped2) t2
ON ST_Intersects(t1.geom, t2.geom)	   
        ', new_tbl_name, join_tbl_name);
		
-- Step 2: Add a primary key column
        EXECUTE format('
            ALTER TABLE %I ADD COLUMN gid SERIAL PRIMARY KEY
        ', new_tbl_name);
		
-- Step 3: Add a spatial index
        EXECUTE format('
-- DROP INDEX IF EXISTS ;
CREATE INDEX IF NOT EXISTS %I
    ON %I USING gist
    (geom)
    TABLESPACE pg_default;

        ', index_name, new_tbl_name );

-- Step 4: Add a table comment with the corresponding year label
       EXECUTE format('
           COMMENT ON TABLE %I IS %L
--        ', new_tbl_name, table_comment);


        RAISE NOTICE 'Created new table: % with primary and comment: %', new_tbl_name, table_comment;
    END LOOP;
END $$;

--  it took: 29 min 15 secs.


-- Loop 2
-- Get polygons that intersect protected areas but are not contained by protected areas (i.e., the difference)

DO $$ 
DECLARE 
    i INT;
    new_tbl_name TEXT;
    join_tbl_name TEXT;
	index_name TEXT;
	--year_labels TEXT[] := ARRAY['Change 1 (period 1 vs. period 2)', 'Change 2 (period 2 vs. period 3)', 'Change 3 (period 3 vs. period 4)']; -- Labels for table comments
	table_comment TEXT;
BEGIN
    FOR i IN 1..1 LOOP
        new_tbl_name := 'forest_lcover_2003_diff_v2';  -- New table to be created (e.g., new_table_1, new_table_2)
        join_tbl_name := 'forest_lcover_2003_v1';     -- Table to join (e.g., table_1, table_2)
		index_name := 'forest_lcover_2003_diff_v2_geom_idx'; -- New index name
		table_comment := 'Study area forest polygons that intersect with protected areas but are not fully contained. These forest polygons can be split uo during the geometry operation. [2025-02-03]';	

-- Step 1: Create the new table with all data except the primary key	
        EXECUTE format('  
CREATE TABLE %I AS
SELECT t1.ogc_fid, t1.fid, t1.layer, t1.class, 0 AS status, St_Multi((ST_DUMP(st_difference(t1.geom, t2.geom))).geom)::geometry(MultiPolygon,3978) AS geom
FROM
%I t1
--LEFT JOIN
JOIN					   
(SELECT gid, __gid as gid0, 1 AS status, st_transform(geom, 3978) geom FROM cpcad_dec2020_clipped2) t2
ON ST_Intersects(t1.geom, t2.geom)	   
        ', new_tbl_name, join_tbl_name);
		
-- Step 2: Add a primary key column
        EXECUTE format('
            ALTER TABLE %I ADD COLUMN gid SERIAL PRIMARY KEY
        ', new_tbl_name);
		
-- Step 3: Add a spatial index
        EXECUTE format('
-- DROP INDEX IF EXISTS ;
CREATE INDEX IF NOT EXISTS %I
    ON %I USING gist
    (geom)
    TABLESPACE pg_default;

        ', index_name, new_tbl_name );

-- Step 4: Add a table comment with the corresponding year label
       EXECUTE format('
           COMMENT ON TABLE %I IS %L
--        ', new_tbl_name, table_comment);


        RAISE NOTICE 'Created new table: % with primary and comment: %', new_tbl_name, table_comment;
    END LOOP;
END $$;

--  it took: 00:31:13.606


-- Loop 3
-- Get polygons that do not intersect with protected areas

DO $$ 
DECLARE 
    i INT;
    new_tbl_name TEXT;
    join_tbl_name TEXT;
	index_name TEXT;
	--year_labels TEXT[] := ARRAY['Change 1 (period 1 vs. period 2)', 'Change 2 (period 2 vs. period 3)', 'Change 3 (period 3 vs. period 4)']; -- Labels for table comments
	table_comment TEXT;
BEGIN
    FOR i IN 1..1 LOOP
        new_tbl_name := 'forest_lcover_2003_not_int_v1';  -- New table to be created (e.g., new_table_1, new_table_2)
        join_tbl_name := 'forest_lcover_2003_v1';     -- Table to join (e.g., table_1, table_2)
		index_name := 'forest_lcover_2003_not_int_v1_geom_idx'; -- New index name
		table_comment := 'Study area forest polygons that do not intersect with protected areas. [2025-01-31]';	
	

-- Step 1: Create the new table with all data except the primary key	
        EXECUTE format('   
CREATE TABLE %I AS
SELECT t1.ogc_fid, t1.fid, t1.layer, t1.class, 0 AS status, t1.geom::geometry(MultiPolygon,3978) AS geom
FROM
%I t1
LEFT JOIN
(SELECT gid, __gid as gid0, 1 AS status, st_transform(geom, 3978) geom FROM cpcad_dec2020_clipped2) t2
ON ST_Intersects(t1.geom, t2.geom)	
WHERE t2.gid is null
        ', new_tbl_name, join_tbl_name);
		
-- Step 2: Add a primary key column
        EXECUTE format('
            ALTER TABLE %I ADD COLUMN gid SERIAL PRIMARY KEY
        ', new_tbl_name);
		
-- Step 3: Add a spatial index
        EXECUTE format('
-- DROP INDEX IF EXISTS public.evi_green_ch3_inter_v1_geom_idx;
CREATE INDEX IF NOT EXISTS %I
    ON %I USING gist
    (geom)
    TABLESPACE pg_default;

        ', index_name, new_tbl_name );

-- Step 4: Add a table comment with the corresponding year label
       EXECUTE format('
           COMMENT ON TABLE %I IS %L
--        ', new_tbl_name, table_comment);

        RAISE NOTICE 'Created new table: % with primary and comment: %', new_tbl_name, table_comment;
    END LOOP;
END $$;

--  it took:  22 min 59 secs.


-- =======================
-- Lets put all together with VIEWS
--DROP VIEW evi_green_ch2_level2_pro_v1;
CREATE VIEW forest_lcover_2003_pro_v1 AS
SELECT 'INT-'||gid::text as gid2, * FROM forest_lcover_2003_int_v1
UNION
SELECT 'DIFF-'||gid::text as gid2, * FROM forest_lcover_2003_diff_v1
UNION
SELECT 'NINT-'||gid::text as gid2, * FROM forest_lcover_2003_not_int_v1
;

COMMENT ON VIEW forest_lcover_2003_pro_v1 Is 'Forest land cover with protected area status. Intersection, difference, and not-intersection are combined in a single object. [2025-02-01]';



