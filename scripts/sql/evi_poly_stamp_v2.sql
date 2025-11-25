-- Spatio-temporal analysis of moving polygons
-- GEOS seems to have a bug. Maybe I could update Postgis
-- Peter R.

-- 2024-11-13

-- Intersection
-- STABLE
-- DROP TABLE p1_p2_inter_v1;
CREATE TABLE p1_p2_inter_v1 AS
SELECT gid, p2_gid, patches, p2_patches, period, p2_period, type, p2_type, st_union(geom) as geom::geometry(Multipolygon, 100000) AS geom
FROM
(SELECT t1.gid,t1.patches, t1.period, t1.type, 
 t2.gid as p2_gid, t2.patches as p2_patches, t2.period as p2_period, t2.type as p2_type, (st_dump(st_intersection(t1.geom,t2.geom))).geom as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p1) t1
	JOIN
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p2) t2
	ON ST_INTERSECTS(t1.geom,t2.geom)
	) t3
	WHERE ST_Dimension(geom) = 2
	GROUP BY gid, p2_gid, patches, p2_patches, period, p2_period, type, p2_type
	;
	
--SELECT * FROM p1_p2_inter_v1 ORDER BY 3 DESC

COMMENT ON TABLE p1_p2_inter_v1 IS 'EVI greening period 1 vs. period 2 change, stable (intersection). [2024-12-13]';


-- This works
-- contraction
DROP VIEW evi_green_ch1_cont_v1;
CREATE VIEW evi_green_ch1_cont_v1 AS
SELECT t3.gid, t3.patches, t3.period, t3.type, array_length(t3.array_p2_patches, 1), 'cont' AS level2, st_area(geom) AS area, geom::geometry(Multipolygon, 100000) AS geom
FROM
(
SELECT t1.gid, t1.patches, t1.period, t1.type, t2.array_p2_patches, st_multi(st_difference(t1.geom, t2.geom)) AS geom FROM 
evi_poly_type1_16d2_p1 t1
JOIN
(
SELECT patches, array_agg(p2_patches) AS array_p2_patches, st_union(geom) AS geom FROM p1_p2_inter_v1
--where patches::int=2927
GROUP BY patches
) t2
ON t1.patches=t2.patches
--where t1.patches::int=2927
) t3
WHERE ST_Dimension(geom) = 2
;

COMMENT ON VIEW evi_green_ch1_cont_v1  IS 'EVI greening period 1 vs. period 2 change, contraction. [2024-12-13]';

-- DISAPPEAR
DROP  VIEW evi_green_ch1_disa_v1;

CREATE VIEW evi_green_ch1_disa_v1 AS
SELECT t3.gid, t3.patches, t3.period, t3.type, 'disa' AS level2, st_area(geom) AS area, geom::geometry(Multipolygon, 100000) AS geom
FROM
(
SELECT t1.gid, t1.patches, t1.period, t1.type, t1.geom AS geom FROM 
evi_poly_type1_16d2_p1 t1
LEFT JOIN
p1_p2_inter_v1 t2
ON t1.patches=t2.patches
where t2.patches is null
) t3
--WHERE ST_Dimension(geom) = 2
--WHERE patches=2961
;

COMMENT ON VIEW evi_green_ch1_disa_v1  IS 'EVI greening period 1 vs. period 2 change, disappearance. [2024-12-13]';


-- GENERATED
DROP VIEW evi_green_ch1_genr_v1;
CREATE VIEW evi_green_ch1_genr_v1 AS
SELECT t3.gid, t3.patches, t3.period, t3.type, 'genr' as level2, st_area(geom) AS area, geom::geometry(Multipolygon, 100000) AS geom
FROM
(
SELECT t1.gid, t1.patches, t1.period, t1.type, t1.geom AS geom FROM 
evi_poly_type1_16d2_p2 t1
LEFT JOIN
p1_p2_inter_v1 t2
ON t1.patches=t2.p2_patches
where t2.p2_patches is null
) t3
--WHERE ST_Dimension(geom) = 2
--WHERE patches=2961
;
COMMENT ON VIEW evi_green_ch1_genr_v1  IS 'EVI greening period 1 vs. period 2 change, generation. [2024-12-13]';


-- Expansion
DROP VIEW evi_green_ch1_expn_v1;

CREATE VIEW evi_green_ch1_expn_v1 AS
SELECT t3.gid, t3.patches, t3.period, t3.type, array_length(t3.array_p1_patches, 1), 'expn' AS level2, st_area(geom) AS area, geom::geometry(Multipolygon, 100000) AS geom
FROM
(
SELECT t1.gid, t1.patches, t1.period, t1.type, t2.array_p1_patches, st_multi(st_difference(t1.geom, t2.geom)) AS geom FROM 
evi_poly_type1_16d2_p2 t1
JOIN
(
SELECT p2_patches, array_agg(patches) AS array_p1_patches, st_union(geom) AS geom FROM p1_p2_inter_v1
--where p2_patches::int=4838
GROUP BY p2_patches
) t2
ON t1.patches=t2.p2_patches
--where t1.patches::int=4838
) t3
WHERE ST_Dimension(geom) = 2
;

COMMENT ON VIEW evi_green_ch1_expn_v1  IS 'EVI greening period 1 vs. period 2 change, expansion. [2024-12-13]';


SELECT row_number() over () as rowid, t1.*
FROM
(
SELECT gid, patches, 'stable' level2, geom FROM p1_p2_inter_v1
UNION ALL
SELECT gid, patches, level2, geom FROM evi_green_ch1_cont_v1 
UNION ALL
SELECT gid, patches, level2 ,geom FROM evi_green_ch1_disa_v1 
UNION ALL
SELECT gid, patches, level2 , geom FROM evi_green_ch1_genr_v1 
UNION ALL
SELECT gid, patches, level2 ,geom FROM evi_green_ch1_expn_v1 ) t1
-- 10355

-- To do
-- - cleam QGIS
-- - test terra polys
-- - lyr.1 to patches
-- - prefix p2 fields?