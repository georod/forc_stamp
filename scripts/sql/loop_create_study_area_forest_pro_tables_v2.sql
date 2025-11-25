-- ================================================================
-- Link study area forest polygons with protected area status
-- ================================================================
-- 2025-02-03
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
-- Note that early version were worng given that I was getting the cartessia product. This have been corrected.
-- Note that NOT intersection was not needed here as I am st_union all polygons first
-- I may need to fix all 9 chnage tables

-- Prep the forest cover layer
-- Index not need as sql created index duirng importing
ALTER TABLE forest_lcover_2003_v1 ADD COLUMN class varchar(30);
UPDATE forest_lcover_2003_v1 set class='forest';

CREATE TABLE forest_lcover_2003_int_v3 AS
SELECT t1.gid as gid_for, t2.gid as gid_cpcad, forest, status, St_Multi((ST_DUMP(st_intersection(t1.geom, t2.geom))).geom)::geometry(MultiPolygon,3978) AS geom
FROM
(SELECT 1 as gid, 1 as forest, st_union(geom) as geom FROM forest_lcover_2003_v1) t1
--LEFT JOIN
JOIN					   
(SELECT 1 as gid, 1 as status, st_union(geom) as geom FROM (SELECT gid, __gid as gid0, st_transform(geom, 3978) geom FROM cpcad_dec2020_clipped2) t0) t2
ON ST_Intersects(t1.geom, t2.geom);

-- 2 min 59 secs.

SELECT * FROM forest_lcover_2003_int_v3 ;
--5175
-- 3695

--CREATE TABLE forest_lcover_2003_diff_v3 AS
--SELECT * FROM forest_lcover_2003_cpcad_union_v1;

 ALTER TABLE forest_lcover_2003_int_v3 ADD COLUMN gid SERIAL PRIMARY KEY;
 
 CREATE INDEX IF NOT EXISTS forest_lcover_2003_int_v3_geom_idx
    ON forest_lcover_2003_int_v3 USING gist
    (geom)
    TABLESPACE pg_default;
	
COMMENT ON TABLE forest_lcover_2003_int_v3 IS 'Study area forest polygons that intersect with protected areas. These are the forest intersection (clip) polygons [2025-02-03]';	


CREATE TABLE forest_lcover_2003_diff_v3 AS
SELECT t1.gid as gid_for, t2.gid as gid_cpcad, forest, status, St_Multi((ST_DUMP(st_difference(t1.geom, t2.geom))).geom)::geometry(MultiPolygon,3978) AS geom
FROM
(SELECT 1 as gid, 1 as forest, st_union(geom) as geom FROM forest_lcover_2003_v1) t1
--LEFT JOIN
JOIN					   
(SELECT 1 as gid, 1 as status, st_union(geom) as geom FROM (SELECT gid, __gid as gid0, st_transform(geom, 3978) geom FROM cpcad_dec2020_clipped2) t0) t2
ON ST_Intersects(t1.geom, t2.geom);

-- 2 min 59 secs.

SELECT * FROM forest_lcover_2003_cpcad_union_v1
--5775

--CREATE TABLE forest_lcover_2003_diff_v3 AS
--SELECT * FROM forest_lcover_2003_cpcad_union_v1;

 ALTER TABLE forest_lcover_2003_diff_v3 ADD COLUMN gid SERIAL PRIMARY KEY;
 
 CREATE INDEX IF NOT EXISTS forest_lcover_2003_diff_v3_geom_idx
    ON forest_lcover_2003_diff_v3 USING gist
    (geom)
    TABLESPACE pg_default;
	
COMMENT ON TABLE forest_lcover_2003_diff_v3 IS 'Study area forest polygons that intersect with protected areas but are not fully contained. These are the forest difference polygons [2025-02-03]';	


-- =======================
-- Lets put all together with VIEWS
-- DROP VIEW evi_green_ch2_level2_pro_v1;
CREATE OR REPLACE VIEW forest_lcover_2003_pro_v3 AS
SELECT * FROM
(
SELECT 'INT-'||gid::text as gid2, gid_for, gid_cpcad, forest, 1 AS status, geom::geometry(MultiPolygon,3978) AS geom FROM forest_lcover_2003_int_v3
--3695
UNION ALL
SELECT 'DIFF-'||gid::text as gid2, gid_for, gid_cpcad, forest, 0 AS status, geom::geometry(MultiPolygon,3978) AS geom FROM forest_lcover_2003_diff_v3
--5175
) t1
;
--8870

COMMENT ON VIEW forest_lcover_2003_pro_v3 Is 'Forest land cover with protected area status. Intersection, difference, and not-intersection are combined in a single object. [2025-02-03]';


