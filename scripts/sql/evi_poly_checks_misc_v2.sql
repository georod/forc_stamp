SELECT *
FROM public.evi_poly_type1_16d_p2 a
INNER JOIN public.evi_poly_type1_16d_p2 b ON 
   (a.geom && b.geom AND ST_Relate(a.geom, b.geom, '2********'))
WHERE a.ctid != b.ctid
LIMIT 1

-- evi_poly_type1_16d_p1 & evi_poly_type1_16d_p2 are fine

SELECT *, st_intersection(a.geom, b.geom) as geom3
FROM public.evi_poly_type1_16d_p1 a
INNER JOIN public.evi_poly_type1_16d_p2 b ON 
   (a.geom && b.geom AND ST_Relate(a.geom, b.geom, '2********'))
WHERE a.ctid != b.ctid
AND a.gid=18 and b.gid=24
LIMIT 3

SELECT *, st_intersection(a.geom, b.geom) as geom3
FROM public.evi_poly_type1_16d2_p1 a
INNER JOIN public.evi_poly_type1_16d2_p2 b ON 
   (a.geom && b.geom AND ST_Relate(a.geom, b.geom, '2********'))
WHERE a.ctid != b.ctid
AND a.gid=18 --and b.gid=24
LIMIT 3