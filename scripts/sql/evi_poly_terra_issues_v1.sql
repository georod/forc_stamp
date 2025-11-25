-- R terra polygons issues
-- 2024-12-14

-- This shows that R terra produced polygons with issues
-- Here I am using terra patch function with queen (8) neighbours
CREATE TABLE evi_green_ch1_inter_terra_v1 AS
SELECT gid, p2_gid, patches, p2_patches, period, p2_period, type, p2_type, 'stbl' AS level2, st_multi(st_union(geom))::geometry(Multipolygon, 100000) AS geom
FROM
(SELECT t1.gid,t1.patches, t1.period, t1.type, 
 t2.gid as p2_gid, t2.patches as p2_patches, t2.period as p2_period, t2.type as p2_type, (st_dump(st_intersection(t1.geom,t2.geom))).geom as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d_p1) t1
	JOIN
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d_p2) t2
	ON ST_INTERSECTS(t1.geom,t2.geom)
	) t3
	WHERE ST_Dimension(geom) = 2
	GROUP BY gid, p2_gid, patches, p2_patches, period, p2_period, type, p2_type
	;
	
--SELECT count(*) FROM evi_green_ch1_inter_terra_v1;

-- ERRORS
--With terra rook & R 4.1
--ERROR:  GEOSIntersects: TopologyException: side location conflict at -6041366.16716576 5130725.0228255345 

--SQL state: XX000

--With terra queen & R 4.1
--ERROR:  lwgeom_intersection_prec: GEOS Error: TopologyException: Input geom 0 is invalid: Self-intersection at -6064300.1466338923 5131188.3355420614 

--SQL state: XX000