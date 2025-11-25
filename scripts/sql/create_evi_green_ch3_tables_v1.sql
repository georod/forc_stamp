-- CREATE evi_green_ch3 intersection tables & related views

-- 2024-12-14
-- Peter R.


--DROP TABLE evi_green_ch3_inter_v1;

--ALTER TABLE evi_poly_type1_16d2_p3 RENAME COLUMN "lyr.1" to patches;
--ALTER TABLE evi_poly_type1_16d2_p4 RENAME COLUMN "lyr.1" to patches;

DROP TABLE IF EXISTS evi_green_ch3_inter_v1;
CREATE TABLE evi_green_ch3_inter_v1 AS
SELECT row_number() over () as rowid, gid, p2_gid, patches, p2_patches, period, p2_period, type, p2_type, 'stbl' AS level2, st_multi(st_union(geom))::geometry(Multipolygon, 100000) AS geom
FROM
(SELECT t1.gid,t1.patches, t1.period, t1.type, 
 t2.gid as p2_gid, t2.patches as p2_patches, t2.period as p2_period, t2.type as p2_type, (st_dump(st_intersection(t1.geom,t2.geom))).geom as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p3) t1
	JOIN
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p4) t2
	ON ST_INTERSECTS(t1.geom,t2.geom)
	) t3
	WHERE ST_Dimension(geom) = 2
	GROUP BY gid, p2_gid, patches, p2_patches, period, p2_period, type, p2_type
	;

--ALTER TABLE evi_green_ch3_inter_v1 ADD CONSTRAINT evi_green_ch3_inter_v1_pkey PRIMARY KEY (gid);
ALTER TABLE evi_green_ch3_inter_v1 ADD CONSTRAINT evi_green_ch3_inter_v1_pkey PRIMARY KEY (rowid);

COMMENT ON TABLE evi_green_ch3_inter_v1 IS 'EVI greening period 3 vs. period 4 change, stable polygons (intersection). [2024-12-14]';

-- Index: evi_poly_type1_16d2_p1_geom_idx

-- DROP INDEX IF EXISTS public.evi_poly_type1_16d2_p1_geom_idx;

CREATE INDEX IF NOT EXISTS evi_green_ch3_inter_v1_geom_idx
    ON public.evi_green_ch3_inter_v1 USING gist
    (geom)
    TABLESPACE pg_default;
	

-- This works
-- contraction
DROP VIEW IF EXISTS evi_green_ch3_cont_v1;
CREATE VIEW evi_green_ch3_cont_v1 AS
SELECT t3.gid, t3.patches, t3.period, t3.type, array_length(t3.array_p2_patches, 1), 'cont' AS level2, st_area(geom) AS area, geom::geometry(Multipolygon, 100000) AS geom
FROM
(
SELECT t1.gid, t1.patches, t1.period, t1.type, t2.array_p2_patches, st_multi(st_difference(t1.geom, t2.geom)) AS geom FROM 
evi_poly_type1_16d2_p3 t1
JOIN
(
SELECT patches, array_agg(p2_patches) AS array_p2_patches, st_union(geom) AS geom FROM evi_green_ch3_inter_v1
--where patches::int=2927
GROUP BY patches
) t2
ON t1.patches=t2.patches
--where t1.patches::int=2927
) t3
WHERE ST_Dimension(geom) = 2
;

COMMENT ON VIEW evi_green_ch3_cont_v1  IS 'EVI greening period 3 (2013-2017) vs. period 4 (2018-2022) change, contraction. [2024-12-13]';

-- DISAPPEAR
DROP VIEW IF EXISTS evi_green_ch3_disa_v1;
CREATE VIEW evi_green_ch3_disa_v1 AS
SELECT t3.gid, t3.patches, t3.period, t3.type, 'disa' AS level2, st_area(geom) AS area, geom::geometry(Multipolygon, 100000) AS geom
FROM
(
SELECT t1.gid, t1.patches, t1.period, t1.type, t1.geom AS geom FROM 
evi_poly_type1_16d2_p3 t1
LEFT JOIN
evi_green_ch3_inter_v1 t2
ON t1.patches=t2.patches
where t2.patches is null
) t3
--WHERE ST_Dimension(geom) = 2
--WHERE patches=2961
;

COMMENT ON VIEW evi_green_ch3_disa_v1  IS 'EVI greening period 3 (2013-2017) vs. period 4 (2018-2022) change, disappearance. [2024-12-13]';


-- GENERATED
DROP VIEW IF EXISTS evi_green_ch3_genr_v1;
CREATE VIEW evi_green_ch3_genr_v1 AS
SELECT t3.gid, t3.patches, t3.period, t3.type, 'genr' as level2, st_area(geom) AS area, geom::geometry(Multipolygon, 100000) AS geom
FROM
(
SELECT t1.gid, t1.patches, t1.period, t1.type, t1.geom AS geom FROM 
evi_poly_type1_16d2_p4 t1
LEFT JOIN
evi_green_ch3_inter_v1 t2
ON t1.patches=t2.p2_patches
where t2.p2_patches is null
) t3
--WHERE ST_Dimension(geom) = 2
--WHERE patches=2961
;
COMMENT ON VIEW evi_green_ch3_genr_v1  IS 'EVI greening period 3 (2013-2017) vs. period 4 (2018-2022) , generation. [2024-12-13]';


-- Expansion
DROP VIEW IF EXISTS evi_green_ch3_expn_v1;

CREATE VIEW evi_green_ch3_expn_v1 AS
SELECT t3.gid, t3.patches, t3.period, t3.type, array_length(t3.array_p1_patches, 1), 'expn' AS level2, st_area(geom) AS area, geom::geometry(Multipolygon, 100000) AS geom
FROM
(
SELECT t1.gid, t1.patches, t1.period, t1.type, t2.array_p1_patches, st_multi(st_difference(t1.geom, t2.geom)) AS geom FROM 
evi_poly_type1_16d2_p4 t1
JOIN
(
SELECT p2_patches, array_agg(patches) AS array_p1_patches, st_union(geom) AS geom FROM evi_green_ch3_inter_v1
--where p2_patches::int=4838
GROUP BY p2_patches
) t2
ON t1.patches=t2.p2_patches
--where t1.patches::int=4838
) t3
WHERE ST_Dimension(geom) = 2
;

COMMENT ON VIEW evi_green_ch3_expn_v1  IS 'EVI greening period 3 (2013-2017) vs. period 4 (2018-2022), expansion. [2024-12-13]';

DROP VIEW IF EXISTS evi_green_ch3_level2_v1;
CREATE VIEW evi_green_ch3_level2_v1 AS
SELECT row_number() over () as rowid, gid, patches, period, level2, geom::geometry(Multipolygon, 100000) AS geom
FROM
(
SELECT gid, patches, period, level2, geom FROM evi_green_ch3_inter_v1
UNION ALL
SELECT gid, patches, period, level2, geom FROM evi_green_ch3_cont_v1 
UNION ALL
SELECT gid, patches, period, level2, geom FROM evi_green_ch3_disa_v1 
UNION ALL
SELECT gid, patches, period, level2, geom FROM evi_green_ch3_genr_v1 
UNION ALL
SELECT gid, patches, period, level2, geom FROM evi_green_ch3_expn_v1 
) t1;
-- 10355

COMMENT ON VIEW evi_green_ch3_level2_v1 IS 'EVI green change 3 (p3 vs. p4), stamp Level 2. [2024-12-14]';