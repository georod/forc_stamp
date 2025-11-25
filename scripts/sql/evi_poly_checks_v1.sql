-- It seems pgAdmin is not rendering correctly.Actually my queries were wrong
-- No need for JOIN
-- I got the queries wrong
-- QGIS works fine

-- union
SELECT *
FROM
(
SELECT t1.gid, t1.patches, t1.period, t1.type,t1.geom
	FROM public.evi_poly_type1_16d_p1 t1 WHERE gid=18
UNION
	SELECT t2.* FROM public.evi_poly_type1_16d_p2 t2
	JOIN 
	public.evi_poly_type1_16d_p1 t1 
	ON ST_INTERSECTS(t1.geom, t2.geom) WHERE t1.gid=18
) t3
	;


-- intersection
SELECT t1.gid, t1.patches, t1.period, t1.type, t2.geom
	FROM public.evi_poly_type1_16d_p1 t1
	JOIN
	public.evi_poly_type1_16d_p2 t2
	ON ST_INTERSECTS(t1.geom, t2.geom)
	WHERE t1.gid=18
	;


-- stable
SELECT t1.gid, t1.patches, t1.period, t1.type, t1.geom, t2.geom, st_intersection(t1.geom, t2.geom)
	FROM public.evi_poly_type1_16d2_p1 t1
	JOIN
	public.evi_poly_type1_16d2_p2 t2
	ON  --ST_CONTAINS (t1.geom, t2.geom)
	ST_INTERSECTS(t1.geom, t2.geom) --AND ST_TOUCHES(t1.geom, t2.geom)='F'
	WHERE t1.gid=18
	;
	
SELECT t1.gid, t1.patches, t1.period, t1.type, st_intersection(t1.geom, t2.geom)
	FROM public.evi_poly_type1_16d_p1 t1
	JOIN
	public.evi_poly_type1_16d_p2 t2
	ON  ST_TOUCHES(t1.geom, t2.geom)
	--ST_INTERSECTS(t1.geom, t2.geom) AND ST_TOUCHES(t1.geom, t2.geom)='F'
	WHERE t1.gid=18
	;
	
SELECT t1.gid, t1.patches, t1.period, t1.type, t1.geom, st_intersection(t1.geom, t2.geom)
	FROM public.evi_poly_type1_16d_p1 t1
	JOIN
	public.evi_poly_type1_16d_p2 t2
	ON  ST_OVERLAPS(t1.geom, st_buffer(t2.geom, 115))
	--ST_INTERSECTS(t1.geom, t2.geom) AND ST_TOUCHES(t1.geom, t2.geom)='F'
	WHERE t1.gid=18
	;
	
SELECT t1.gid, t1.patches, t1.period, t1.type, t1.geom, st_intersection(t1.geom, t2.geom)
	FROM public.evi_poly_type1_16d2_p1 t1
	JOIN
	public.evi_poly_type1_16d2_p2 t2
	ON  ST_OVERLAPS(t1.geom, t2.geom)
	--ST_INTERSECTS(t1.geom, t2.geom) AND ST_TOUCHES(t1.geom, t2.geom)='F'
	WHERE t1.gid=18
	;

-- STange QGIS does not show a 115 m ovelap
SELECT t1.gid, t1.patches, t1.period, t1.type, t1.geom, st_intersection(t1.geom, t2.geom)
	FROM public.evi_poly_type1_16d_p1 t1
	JOIN
	public.evi_poly_type1_16d_p2 t2
	ON  ST_OVERLAPS(st_transform(t1.geom, 100000), st_transform(t2.geom, 100000))
	--ST_INTERSECTS(t1.geom, t2.geom) AND ST_TOUCHES(t1.geom, t2.geom)='F'
	WHERE t1.gid=18
	;


--SELECT t1.gid, t1.patches, t1.period, t1.type, st_intersection(t1.geom, t2.geom)
--	FROM public.evi_poly_type1_16d_p1 t1
--	JOIN
--	public.evi_poly_type1_16d_p2 t2
--	ON ST_INTERSECTS(st_buffer(t1.geom, -5), st_buffer(t2.geom, -5))
--	WHERE t1.gid=18
--	;

-- stable
SELECT t1.gid, t1.patches, t1.period, t1.type, st_intersection(t1.geom, t2.geom)
FROM 
	(SELECT gid, patches, period, type, st_buffer(geom, -5) geom FROM public.evi_poly_type1_16d_p1) t1
	JOIN
	(SELECT gid, patches, period, type, st_buffer(geom, -5) geom FROM public.evi_poly_type1_16d_p2) t2
	ON ST_INTERSECTS(t1.geom, t2.geom)
	WHERE t1.gid=18
	;
	
-- STABLE with correct geom	
SELECT t1.gid, t1.patches, t1.period, t1.type, st_intersection(t1.geom, t2.geom)
FROM 
	(SELECT gid, patches, period, type, geom FROM public.evi_poly_type1_16d2_p1) t1
	JOIN
	(SELECT gid, patches, period, type, geom FROM public.evi_poly_type1_16d2_p2) t2
	ON ST_INTERSECTS(t1.geom, t2.geom)
	WHERE t1.gid=18
	;

-- Expansion, no Generation
SELECT t1.gid, t1.patches, t1.period, t1.type, st_difference(t2.geom, t1.geom)
FROM 
	(SELECT gid, patches, period, type, st_buffer(geom, -5) geom FROM public.evi_poly_type1_16d_p1) t1
	JOIN
	(SELECT gid, patches, period, type, st_buffer(geom, -5) geom FROM public.evi_poly_type1_16d_p2) t2
	ON ST_INTERSECTS(t1.geom, t2.geom)
	WHERE t1.gid=18
	;
	
SELECT t1.gid, t1.patches, t1.period, t1.type, st_difference(t2.geom, t1.geom)
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d_p1) t1
	JOIN
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d_p2) t2
	ON ST_INTERSECTS(t1.geom, t2.geom)
	WHERE t1.gid=18
	;
	
SELECT t1.gid, t1.patches, t1.period, t1.type, st_difference(t2.geom, t1.geom)
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p1) t1
	JOIN
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p2) t2
	ON ST_INTERSECTS(t1.geom, t2.geom)
	WHERE t1.gid=18
	;
	
	
SELECT st_difference(r2.geom,st_union(r1.geom)) as geom
    FROM rect1 r1, rect2 r2
    GROUP BY r2.geom
	
	
SELECT t2.gid, st_difference(t2.geom, st_union(t1.geom)) as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p1) t1
	,
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p2) t2
	
	--WHERE t1.gid=18
	GROUP BY t2.gid,t2.geom
	;
	
-- I got the queries wrong.

WITH t10 AS
(
	SELECT t1.gid, t1.period, t1.type,'disappearance' AS event, st_difference(t1.geom, st_union(t2.geom)) as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p1) t1
	,
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p2) t2
	
	--WHERE t1.gid=18
	GROUP BY t1.gid, t1.period, t1.type, t1.geom
	
UNION ALL

SELECT t2.gid, t2.period, t2.type,'generation' AS event, st_difference(t2.geom, st_union(t1.geom)) as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p1) t1 -- 29
	,
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p2) t2 --51
 --WHERE t1.gid=18
	GROUP BY t2.gid, t2.period, t2.type, t2.geom
	) SELECT gid, period, type, event,(st_dump(geom)).geom from t10 ORDER BY 2,1
	
select 29*51 -- 1479

-- this is QGIS sym diff
SELECT gid, period, type, event, st_union(geom) AS geom
FROM
(WITH t10 AS
(
	SELECT t1.gid, t1.period, t1.type,'disappearance' AS event, st_difference(t1.geom, st_union(t2.geom)) as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p1) t1
	,
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p2) t2
	
	--WHERE t1.gid=18
	GROUP BY t1.gid, t1.period, t1.type, t1.geom
	
UNION ALL

SELECT t2.gid, t2.period, t2.type,'generation' AS event, st_difference(t2.geom, st_union(t1.geom)) as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p1) t1 -- 29
	,
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p2) t2 --51
 --WHERE t1.gid=18
	GROUP BY t2.gid, t2.period, t2.type, t2.geom
	) SELECT gid, period, type, event,(st_dump(geom)).geom AS geom from t10) t11
	GROUP BY gid, period, type, event
	ORDER BY 2,1




WITH T1 AS
(
    SELECT st_difference(r1.geom,st_union(r2.geom)) as geom
    FROM rect1 r1, rect2 r2
    GROUP BY r1.geom

    UNION

    SELECT st_difference(r2.geom,st_union(r1.geom)) as geom
    FROM rect1 r1, rect2 r2
    GROUP BY r2.geom
)
SELECT (st_dump(geom)).geom from T1

	
-- Contraction, Disappearance
-- (SELECT t1.gid, t1.patches, t1.period, t1.type, t2.gid, (st_difference(t1.geom, t2.geom)) geom
-- FROM 
-- 	(SELECT gid, patches, period, type, st_buffer(geom, -5) geom FROM public.evi_poly_type1_16d_p1) t1
-- 	JOIN
-- 	(SELECT gid, patches, period, type, st_buffer(geom, -5) geom FROM public.evi_poly_type1_16d_p2) t2
-- 	ON ST_INTERSECTS(t1.geom, t2.geom)
-- 	WHERE t1.gid=18)
-- 	;
	
-- Contraction, Disappearance
SELECT t4.gid, t4.patches, t4.period, t4.type, (st_difference(t4.geom, t3.geom)) geom
FROM 
	-- This computes what needs to be unioned
	(
		SELECT t1.gid, st_union(t2.geom) geom 
	 FROM (SELECT gid, patches, period, type, st_buffer(geom, -10) geom FROM public.evi_poly_type1_16d_p1) t1
	JOIN
	(SELECT gid, patches, period, type, st_buffer(geom, -5) geom FROM public.evi_poly_type1_16d_p2) t2
	ON ST_INTERSECTS(t1.geom, t2.geom)
		--WHERE t1.gid=18
		GROUP by t1.gid
	
	) t3
 JOIN
(SELECT gid, patches, period, type, st_buffer(geom, -5) geom FROM public.evi_poly_type1_16d_p1) t4
 ON ST_INTERSECTS(t3.geom, t4.geom)

	;

--
SELECT distinct t4.gid, t4.patches, t4.period, t4.type, 
(st_difference(t4.geom, t3.geom)) geom
FROM 
	-- This computes what needs to be unioned
	(
	SELECT t1.gid, st_union(t2.geom) geom 
	 FROM (SELECT gid, patches, period, type, geom FROM public.evi_poly_type1_16d2_p1) t1
	JOIN
	(SELECT gid, patches, period, type, geom FROM public.evi_poly_type1_16d2_p2) t2
	ON ST_OVERLAPS(t1.geom, t2.geom)
		--WHERE t1.gid=18
		GROUP by t1.gid
	) t3
 JOIN
(SELECT gid, patches, period, type, geom FROM public.evi_poly_type1_16d2_p1) t4
 ON ST_INTERSECTS(t3.geom, t4.geom)
 ORDER BY 1
	;

	
--- misc
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

SELECT *
FROM mov_poly_union1
WHERE array_length(gid_p2_array,1)=1 AND gid_p2_array[1]=0

SELECT *
FROM mov_poly_union1
WHERE array_length(gid_p2_array,1)=1 AND gid_p2_array[1]=0

SELECT *
FROM mov_poly_union1
WHERE array_length(gid_p2_array,1)> 1


-- color is light no dups, but touches is TRUE
CREATE VIEW mov_poly_disjoint_v1 AS
	SELECT t1.gid, t1.patches, t1.period, t1.type, 'dissapear' AS event, t1.geom
	FROM public.evi_poly_type1_16d_p1 t1
	LEFT JOIN 
	public.evi_poly_type1_16d_p2 t2
	ON ST_INTERSECTS(t1.geom, t2.geom) WHERE t2.gid IS NULL
	UNION
	SELECT t2.gid, t2.patches, t2.period, t2.type, 'generation' AS event, t2.geom
	FROM public.evi_poly_type1_16d_p1 t1
	RIGHT JOIN 
	public.evi_poly_type1_16d_p2 t2
	ON ST_INTERSECTS(t1.geom, t2.geom) WHERE t1.gid IS NULL
;

-- Improved version
-- Ref:
-- https://gis.stackexchange.com/questions/302458/symmetrical-difference-between-two-layers-using-postgis
-- Symmetric difference
DROP VIEW mov_poly_dis_gen_v1;
CREATE OR REPLACE VIEW mov_poly_dis_gen_v1 AS
SELECT gid, patches, period, type, event, st_union(geom) AS geom
FROM
(WITH t10 AS
(
	SELECT t1.gid, t1.patches, t1.period, t1.type,'disappearance' AS event, st_difference(t1.geom, st_union(t2.geom)) as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p1) t1
	,
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p2) t2
	
	--WHERE t1.gid=18
	GROUP BY t1.gid, t1.patches,t1.period, t1.type, t1.geom
	
UNION ALL

SELECT t2.gid, t2.patches, t2.period, t2.type,'generation' AS event, st_difference(t2.geom, st_union(t1.geom)) as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p1) t1 -- 29
	,
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p2) t2 --51
 --WHERE t1.gid=18
	GROUP BY t2.gid, t2.patches, t2.period, t2.type, t2.geom
	) SELECT gid, patches, period, type, event,(st_dump(geom)).geom AS geom from t10
WHERE ST_Dimension(t10.geom) = 2) t11
	GROUP BY gid, patches, period, type, event;
	--ORDER BY 2,1
	
-- stable poly
-- you need dimen=2 as lines and point are byproducts
DROP VIEW mov_poly_stable_v1;

CREATE OR REPLACE VIEW mov_poly_stable_v1 AS
SELECT gid, patches, period,type,event, geom
FROM
(SELECT t1.gid, t1.patches, t1.period, t1.type,'stable' AS event, (st_dump(st_intersection(t1.geom,t2.geom))).geom as geom
FROM 
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p1) t1
	JOIN
	(SELECT gid, patches, period, type,  geom FROM public.evi_poly_type1_16d2_p2) t2
	ON ST_INTERSECTS(t1.geom,t2.geom)) t10
	WHERE ST_Dimension(t10.geom) = 2
	;
	
-- 
	
-- Contraction is just stable polygon smaller than parent poly
DROP VIEW mov_poly_contr_v1;

CREATE VIEW mov_poly_contr_v1 AS
SELECT t11.gid, t11.patches, t11.period, t11.type, 'contraction' AS event, t11.geom
FROM
(SELECT * from mov_poly_dis_gen_v1) t11
	--UNION ALL
	JOIN
	(SELECT gid, patches, period, type, geom FROM public.evi_poly_type1_16d2_p1) t12
	ON ST_CONTAINS(t12.geom,t11.geom);
	
-- Put it all together
DROP VIEW mov_poly_test2 ;
CREATE VIEW mov_poly_test2 AS
SELECT * FROM mov_poly_dis_gen_v1
UNION ALL
SELECT * FROM mov_poly_stable_v1

UNION ALL
SELECT * FROM  mov_poly_contr_v1