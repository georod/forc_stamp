DROP VIEW mov_poly_union1;

CREATE VIEW mov_poly_union1 AS
SELECT gid, array_agg(gid_p2) gid_p2_array, array_agg(period) period_array, array_agg(type) as type_array, ((st_dump(st_union(geom))).geom)::geometry(Polygon, 100002) geom
FROM
(
SELECT t1.gid, 0 as gid_p2, t1.patches, t1.period, t1.type,t1.geom
	FROM public.evi_poly_type1_16d_p1 t1 --WHERE gid=18
UNION
	SELECT t1.gid, t2.gid as gid_p2, t2.patches, t2.period, t2.type,t2.geom 
	FROM public.evi_poly_type1_16d_p2 t2
	JOIN 
	public.evi_poly_type1_16d_p1 t1 
	ON ST_INTERSECTS(t1.geom, t2.geom) --WHERE t1.gid=18
) t3
GROUP BY gid;

CREATE VIEW mov_poly_union2 AS
SELECT gid, array_agg(gid_p2) gid_p2_array, array_agg(period) period_array, array_agg(type) as type_array, st_multi(st_union(geom))::geometry(Multipolygon, 100002) geom
FROM
(
SELECT t1.gid, 0 as gid_p2, t1.patches, t1.period, t1.type,t1.geom
	FROM public.evi_poly_type1_16d_p1 t1 --WHERE gid=18
UNION
	SELECT t1.gid, t2.gid as gid_p2, t2.patches, t2.period, t2.type, t1.geom, t2.geom 
	FROM public.evi_poly_type1_16d_p2 t2
	JOIN 
	public.evi_poly_type1_16d_p1 t1 
	ON ST_INTERSECTS(t1.geom, t2.geom) --WHERE t1.gid=18
) t3
GROUP BY gid;

-- diss
SELECT *
FROM mov_poly_union1
WHERE array_length(gid_p2_array,1)=1 AND gid_p2_array[1]=0

SELECT t2.*, t1.*, st_difference(t2.geom, t1.geom) as geom2
FROM mov_poly_union1 t1
JOIN
public.evi_poly_type1_16d_p1 t2
ON ST_INTERSECTS(t1.geom, t2.geom)
WHERE array_length(gid_p2_array,1)> 1 AND 0 = ANY(gid_p2_array) AND --
st_touches(t1.geom, t2.geom)
--st_area(t2.geom)> st_area(t1.geom)
