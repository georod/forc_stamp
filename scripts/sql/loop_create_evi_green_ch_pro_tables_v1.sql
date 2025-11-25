-- ================================================================
-- Link EVI trend change polygon tables with protected area status
-- ================================================================
-- 2025-01-30
-- Peter R.
-- PhD Thesis, Chapter 3
-- The aim of the code produced below is to figure out what stamp polygons are within protected areas.
-- This seemed to be a simple task but it not given that you need three queries: st_intersection, st_difference, and not intersection
-- I protected area polygon can split a stamp polygon and in doing so part of the later could be protected and the other part non protected
-- Perhaps I should have gone done the raster route instead of polygons
-- I created this script with the help of ChatGPT. 
-- This script has some differences compared with the browning version (e.g., rowid vs gid)
-- For some reason, the easiest query (not intersect) took the longest fore greening
-- In general the greening queries take much longer than the browning as there are more polygons to process
-- The loop below are only for greening as the browning was done with separate scrips (e.g., create_evi_brown_ch1_pro_tables_v1, ...)
-- At the end of this script there is code to create the VIEWS that combines the tables together


-- Loop 1
-- Create greening tables that intersect with protected areas

DO $$ 
DECLARE 
    i INT;
    new_tbl_name TEXT;
    join_tbl_name TEXT;
	index_name TEXT;
	year_labels TEXT[] := ARRAY['Change 1 (period 1 vs. period 2)', 'Change 2 (period 2 vs. period 3)', 'Change 3 (period 3 vs. period 4)']; -- Labels for table comments
	table_comment TEXT;
BEGIN
    FOR i IN 1..3 LOOP
        new_tbl_name := 'evi_green_ch' || i ||'_level2_int_v2';  -- New table to be created (e.g., new_table_1, new_table_2)
        join_tbl_name := 'evi_green_ch' || i||'_level2_v1';     -- Table to join (e.g., table_1, table_2)
		index_name := 'evi_green_ch' || i ||'_level2_int_v2_geom_idx'; -- New index name
		table_comment := 'EVI greening trend polygon changes (level2) for ' || year_labels[i]||' with protected area status. [2025-01-30]';
		

-- Step 1: Create the new table with all data except the primary key	
        EXECUTE format('
	   
CREATE TABLE %I AS
SELECT t1.gid AS gid_ch, t1.patches, t1.period, t1.level2, t2.gid AS gid_pro, t2.gid0 AS gid0_pro, t2.status, St_Multi((ST_DUMP(st_intersection(t1.geom, t2.geom))).geom)::geometry(MultiPolygon,100000) AS geom
FROM
%I t1
LEFT JOIN
(SELECT gid, __gid as gid0, 1 AS status, st_transform(geom, 100000) geom FROM cpcad_dec2020_clipped2) t2
ON ST_Intersects(t1.geom, t2.geom)	   
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

--  it took: 02:30:22.713


-- Loop 2
-- -- Get polygons that intersect protected areas but are not contained by protected areas (i.e., the difference)

DO $$ 
DECLARE 
    i INT;
    new_tbl_name TEXT;
    join_tbl_name TEXT;
	index_name TEXT;
	year_labels TEXT[] := ARRAY['Change 1 (period 1 vs. period 2)', 'Change 2 (period 2 vs. period 3)', 'Change 3 (period 3 vs. period 4)']; -- Labels for table comments
	table_comment TEXT;
BEGIN
    FOR i IN 1..3 LOOP
        new_tbl_name := 'evi_green_ch' || i ||'_level2_diff_v2';  -- New table to be created (e.g., new_table_1, new_table_2)
        join_tbl_name := 'evi_green_ch' || i||'_level2_v1';     -- Table to join (e.g., table_1, table_2)
		--join_tbl_name := 'evi_green_ch' || i||'_level2_v1'; 
		index_name := 'evi_green_ch' || i ||'_level2_diff_v2_geom_idx'; -- New index name
		table_comment := 'EVI greening trend polygon changes (level2) for ' || year_labels[i]||' with protected area status. These polygons are the difference of the intersection with protected areas. [2025-01-30]';
		

-- Step 1: Create the new table with all data except the primary key	
        EXECUTE format('  
CREATE TABLE %I AS
SELECT t1.gid AS gid_ch, t1.patches, t1.period, t1.level2, t2.gid AS gid_pro, t2.gid0 AS gid0_pro, t2.status, St_Multi((ST_DUMP(st_difference(t1.geom, t2.geom))).geom)::geometry(MultiPolygon,100000) AS geom
FROM
%I t1
LEFT JOIN
(SELECT gid, __gid as gid0, 1 AS status, st_transform(geom, 100000) geom FROM cpcad_dec2020_clipped2) t2
ON ST_Intersects(t1.geom, t2.geom)	   
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

--  it took: 02:33:02.584


-- Loop 3
-- Get polygons that do not intersect with protected areas

DO $$ 
DECLARE 
    i INT;
    new_tbl_name TEXT;
    join_tbl_name TEXT;
	index_name TEXT;
	year_labels TEXT[] := ARRAY['Change 1 (period 1 vs. period 2)', 'Change 2 (period 2 vs. period 3)', 'Change 3 (period 3 vs. period 4)']; -- Labels for table comments
	table_comment TEXT;
BEGIN
    FOR i IN 1..3 LOOP
        new_tbl_name := 'evi_green_ch' || i ||'_level2_not_int_v2';  -- New table to be created (e.g., new_table_1, new_table_2)
        join_tbl_name := 'evi_green_ch' || i||'_level2_v1';     -- Table to join (e.g., table_1, table_2)
		index_name := 'evi_green_ch' || i ||'_level2_not_int_v2_geom_idx'; -- New index name
		table_comment := 'EVI greening trend polygon changes (level2) for ' || year_labels[i]||' that do not intersect with protected areas. [2025-01-30]';
		

-- Step 1: Create the new table with all data except the primary key	
        EXECUTE format('   
CREATE TABLE %I AS
SELECT t1.gid AS gid_ch, t1.patches, t1.period, t1.level2, t2.gid AS gid_pro, t2.gid0 AS gid0_pro, 0 AS status, t1.geom::geometry(MultiPolygon,100000) AS geom
FROM
%I t1
LEFT JOIN
(SELECT gid, __gid as gid0, 1 AS status, st_transform(geom, 100000) geom FROM cpcad_dec2020_clipped2) t2
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

--  it took: 04:13:33.169. Wow! SOmethng must be wrong here.  It is just a simple intersect, no clipping was required


-- =======================
-- Lets put all together with VIEWS
--DROP VIEW evi_green_ch3_level2_pro_v1;
CREATE VIEW evi_green_ch3_level2_pro_v1 AS
SELECT 'INT-'||gid::text as gid2, * FROM evi_green_ch3_level2_int_v2
UNION
SELECT 'DIFF-'||gid::text as gid2, * FROM evi_green_ch3_level2_diff_v2
UNION
SELECT 'NINT-'||gid::text as gid2, * FROM evi_green_ch3_level2_not_int_v2
;

COMMENT ON VIEW evi_green_ch3_level2_pro_v1 Is 'EVI greening trend patches (level2) for Change 3 (period 3 vs. period 4) with protected area status. Intersection, difference, and not-intersection are combined in a single object. [2025-01-30]';


--DROP VIEW evi_green_ch2_level2_pro_v1;
CREATE VIEW evi_green_ch2_level2_pro_v1 AS
SELECT 'INT-'||gid::text as gid2, * FROM evi_green_ch2_level2_int_v2
UNION
SELECT 'DIFF-'||gid::text as gid2, * FROM evi_green_ch2_level2_diff_v2
UNION
SELECT 'NINT-'||gid::text as gid2, * FROM evi_green_ch2_level2_not_int_v2
;

COMMENT ON VIEW evi_green_ch2_level2_pro_v1 Is 'EVI greening trend patches (level2) for Change 2 (period 2 vs. period 3) with protected area status. Intersection, difference, and not-intersection are combined in a single object. [2025-01-30]';


--DROP VIEW evi_green_ch1_level2_pro_v1;
CREATE VIEW evi_green_ch1_level2_pro_v1 AS
SELECT 'INT-'||gid::text as gid2, * FROM evi_green_ch1_level2_int_v2
UNION
SELECT 'DIFF-'||gid::text as gid2, * FROM evi_green_ch1_level2_diff_v2
UNION
SELECT 'NINT-'||gid::text as gid2, * FROM evi_green_ch1_level2_not_int_v2
;

COMMENT ON VIEW evi_green_ch1_level2_pro_v1 Is 'EVI greening trend patches (level2) for Change 1 (period 1 vs. period 2) with protected area status. Intersection, difference, and not-intersection are combined in a single object. [2025-01-30]';



