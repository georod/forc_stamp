-- Spatio-temporal analysis of moving polygons
-- GEOS seems to have a bug. Maybe I could update Postgis. Actually, terra seems to have produced buggy polygons.
-- Peter R.

-- 2024-11-08

-- This didn't work

SELECT postgis_full_version();
--DROP VIEW mov_poly_dis_gen_v2;
--CREATE OR REPLACE VIEW mov_poly_dis_gen_v2 AS
CREATE TABLE mov_poly_dis_gen_v2_tab AS
SELECT gid, patches, period, type, event, st_union(geom) AS geom
FROM
(WITH t10 AS
(
	SELECT * FROM
	(SELECT t1.gid, t1.patches, t1.period, t1.type,'DISA' AS event, st_difference(t1.geom, st_union(t2.geom, 0.001), 0.001) as geom
FROM 
	(SELECT gid, patches, period, type,  st_snaptogrid(geom,0.0001) geom FROM public.evi_poly_type1_16d3_p1) t1
	,
	(SELECT gid, patches, period, type,  st_snaptogrid(geom,0.0001) geom  FROM public.evi_poly_type1_16d3_p2) t2
	
	--WHERE t1.gid=18
		GROUP BY t1.gid, t1.patches,t1.period, t1.type, t1.geom) t10
	WHERE ST_Dimension(t10.geom) = 2
	
UNION ALL

SELECT t2.gid, t2.patches, t2.period, t2.type,'GENR' AS event, st_difference(t2.geom, st_union(t1.geom,0.0001), 0.0001) as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d3_p1) t1 -- 29
	,
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d3_p2) t2 --51
 --WHERE t1.gid=18
	
	GROUP BY t2.gid, t2.patches, t2.period, t2.type, t2.geom
	
	) SELECT gid, patches, period, type, event,(st_dump(geom)).geom AS geom from t10
WHERE ST_Dimension(t10.geom) = 2) t11
	GROUP BY gid, patches, period, type, event;
	
--DROP VIEW mov_poly_stable_v2;

--CREATE OR REPLACE VIEW mov_poly_stable_v2 AS

DROP TABLE p1_p2_inter_v0;

CREATE TABLE p1_p2_inter_v0 AS
SELECT gid, p2_gid, patches, p2_patches, period, p2_period, type, p2_type, st_union(geom) as geom
FROM
(SELECT t1.gid,t1.patches, t1.period, t1.type, 
 t2.gid as p2_gid, t2.patches as p2_patches, t2.period as p2_period, t2.type as p2_type, (st_dump(st_intersection(t1.geom,t2.geom))).geom as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d3_p1) t1
	JOIN
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d3_p2) t2
	ON ST_INTERSECTS(t1.geom,t2.geom)
	) t3
	WHERE ST_Dimension(geom) = 2
	GROUP BY gid, p2_gid, patches, p2_patches, period, p2_period, type, p2_type, geom
	;
	
SELECT * FROM p1_p2_inter_v0 ORDER BY 3

-- 2024-12-10

SELECT t1.gid, "lyr.1", t1.period, t1.type, t1.geom
	FROM public.evi_poly_type1_p1_p2_cont_v1 t1
	LEFT JOIN
	evi_poly_type1_p1_p2_sym_diff_v1 t2
	ON t1."lyr.1"=t2.patches
	WHERE t2.gid is null
	--ON ST_within(t1.geom, t2.geom);
	
-- contraction	
SELECT t1.gid, "lyr.1", t1.period, t1.type, t1.geom, 4326
	FROM public.evi_poly_type1_p1_p2_expan_v1 t1
	LEFT JOIN
	evi_poly_type1_p1_p2_sym_diff_v1 t2
	ON t1."lyr.1"=t2.patches
	WHERE t2.gid is null
	--ON ST_within(t1.geom, t2.geom);
	
-- expansion
-- lyr.1 is patches p2
SELECT t1.gid, "lyr.1", t1.period, t1.type, st_transform(t1.geom, 4326) geom
	FROM public.evi_poly_type1_p1_p2_expan_v1 t1
	LEFT JOIN
	evi_poly_type1_p1_p2_sym_diff_v1 t2
	ON t1."lyr.1"=t2.p2_patches
	WHERE t2.gid is null and "lyr.1"=4838
	order by 2
	
	-- 2024-12-12
	
	-- Expansion	
SELECT t1.gid, --"lyr.1", t1.period, t1.type, 
st_transform(t1.geom, 4326) geom
	FROM public.evi_poly_type1_p1_p2_expan_v1 t1
	LEFT JOIN
	evi_poly_type1_p1_p2_inter_v1 t2
	ON t1."lyr.1"=t2.p2_patches
	WHERE t2.gid is null
	
-- Fragmentation
SELECT t1.gid, --"lyr.1", t1.period, t1.type, 
st_transform(t1.geom, 4326) geom
	FROM public.evi_poly_type1_p1_p2_expan_v1 t1
	LEFT JOIN
	evi_poly_type1_p1_p2_inter_v1 t2
	ON t1."lyr.1"=t2.p2_patches
	WHERE t2.gid is null