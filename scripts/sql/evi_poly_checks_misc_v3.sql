SELECT gid, ST_IsValid(st_buffer(geom, -5)) FROM public.evi_poly_type1_16d_p2;


DROP VIEW mov_poly1;

CREATE OR REPLACE VIEW mov_poly1 AS
SELECT t4.gid, t4.patches, t4.period, t4.type, st_multi((st_difference(t4.geom, t3.geom)))::geometry(Multipolygon, 100002) geom
FROM 
	-- This computes what needs to be unioned
	(
		SELECT t1.gid, st_union(t2.geom) geom 
	 FROM (SELECT gid, patches, period, type, st_buffer(geom, -1) geom FROM public.evi_poly_type1_16d_p1) t1
	JOIN
	(SELECT gid, patches, period, type, st_buffer(geom, -5) geom FROM public.evi_poly_type1_16d_p2) t2
	ON ST_INTERSECTS(t1.geom, t2.geom)
		WHERE t1.gid=18
		GROUP by t1.gid
	
	) t3
 JOIN
(SELECT gid, patches, period, type, st_buffer(geom, -5) geom FROM public.evi_poly_type1_16d_p1) t4
 ON ST_INTERSECTS(t3.geom, t4.geom)

	;
	
SELECT t4.gid, t4.patches, t4.period, t4.type, st_multi((st_difference(t4.geom, t3.geom)))::geometry(Multipolygon, 100002) geom
FROM 
	-- This computes what needs to be unioned
	(
		SELECT t1.gid, st_union(t2.geom) geom 
	 FROM (SELECT gid, patches, period, type, geom FROM public.evi_poly_type1_16d_p1) t1
	JOIN
	(SELECT gid, patches, period, type, geom FROM public.evi_poly_type1_16d_p2) t2
	ON ST_INTERSECTS(t1.geom, t2.geom)
		--WHERE t1.gid=18
		GROUP by t1.gid
	
	) t3
 JOIN
(SELECT gid, patches, period, type, geom FROM public.evi_poly_type1_16d_p1
WHERE gid=18
) t4
 ON ST_INTERSECTS(t3.geom, t4.geom)
	;


SELECT gid, geom
FROM mov_poly_union1
WHERE array_length(gid_p2_array,1)=1 AND gid_p2_array[1]=0
UNION ALL
SELECT t4.gid, --t4.patches, t4.period, t4.type, 
st_multi((st_difference(t4.geom, t3.geom)))::geometry(Multipolygon, 100002) geom
FROM 
	-- This computes what needs to be unioned
	(
		SELECT t1.gid, st_union(t2.geom) geom 
	 FROM (SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d_p1) t1
	JOIN
	(SELECT gid, patches, period, type, geom FROM public.evi_poly_type1_16d_p2) t2
	ON ST_INTERSECTS(t1.geom, t2.geom)
		--WHERE t1.gid=18
		GROUP by t1.gid
	
	) t3
 JOIN
(SELECT gid, patches, period, type, geom FROM public.evi_poly_type1_16d_p1
--where gid=18
) t4
 ON ST_INTERSECTS(t3.geom, t4.geom)

	;	