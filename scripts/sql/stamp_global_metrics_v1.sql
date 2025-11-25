--===============================
-- STAMP global metrics 
-- 2025-11-24

-- Thesis - Chapter 4
-- meter sq to km sq divide by 1e6
-- Some calulatyion were completed in Excel. 

-- ==============================
-- Global metrics 
-- Greening
SELECT 'G' AS trend_poly, t1||'_vs_'||t2 AS comparison, poly_count_t1 AS count1, poly_count_t2 AS count2, round(poly_sum_t1/1e6, 2) AS sum1, round(poly_sum_t2/1e6,2) as sum2,  
nr, ar, round(ar/nr,2) AS aar
FROM
(SELECT t1, t2, poly_count_t1, poly_count_t2, round(poly_count_t2*1.0/poly_count_t1, 2) AS nr,
 poly_sum_t1, poly_sum_t2,
round(poly_sum_t2*1.0/poly_sum_t1*1.0, 2) AS ar
FROM
(SELECT t1.period as t1, t1.count::numeric  as poly_count_t1, (t1.sum::numeric) AS poly_sum_t1, t2.period as t2, t2.count::numeric  as poly_count_t2, t2.sum::numeric AS poly_sum_t2
FROM

(SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type1_16d2_p1
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type1_16d2_p2
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type1_16d2_p3
	GROUP BY period
-- UNION ALL
-- SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
-- 	FROM public.evi_poly_type1_16d2_p4
-- 	GROUP BY period
) t1
	
	JOIN

(SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type1_16d2_p1
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type1_16d2_p2
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type1_16d2_p3
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type1_16d2_p4
	GROUP BY period) t2
	ON t1.period=t2.period-1

	) t3 ) t4
	--order by 2

-- Browning
UNION ALL
SELECT 'B' AS trend_poly, t1||'_vs_'||t2 AS comparison, poly_count_t1 AS count1, poly_count_t2 AS count2, round(poly_sum_t1/1e6, 2) AS sum1, round(poly_sum_t2/1e6,2) as sum2,
nr, ar, round(ar/nr,2) AS aar
FROM
(SELECT t1, t2, poly_count_t1, poly_count_t2, round(poly_count_t2*1.0/poly_count_t1, 2) AS nr,
 poly_sum_t1, poly_sum_t2,
round(poly_sum_t2*1.0/poly_sum_t1*1.0, 2) AS ar
FROM
(SELECT t1.period as t1, t1.count::numeric  as poly_count_t1, (t1.sum::numeric) AS poly_sum_t1, t2.period as t2, t2.count::numeric  as poly_count_t2, t2.sum::numeric AS poly_sum_t2
FROM

(SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type2_16d2_p1
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type2_16d2_p2
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type2_16d2_p3
	GROUP BY period
-- UNION ALL
-- SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
-- 	FROM public.evi_poly_type2_16d2_p4
-- 	GROUP BY period
) t1
	
	JOIN

(SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type2_16d2_p1
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type2_16d2_p2
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type2_16d2_p3
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type2_16d2_p4
	GROUP BY period) t2
	ON t1.period=t2.period-1

	) t3 ) t4
	
	ORDER BY 1, 2
;

-- =======================================
-- Trend polygons as percent of study area

-- Area of study area. The double transformation not really needed.
SELECT gid, id, width, height, area, perimeter, round(st_area(st_transform(st_transform(geom, 4326), 3347))::numeric/1e6,5)
	FROM public.algonquin_env_v1;

-- Trend polygons as percent of study area
SELECT 'G' AS trend_poly, period, count1, sum1, round((sum1::numeric/1e6)/14930.31419*100, 2) as per_agpe
FROM
(SELECT period, count(gid) AS count1, sum(st_area(st_transform(geom, 3347))) sum1
	FROM public.evi_poly_type1_16d2_p1
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type1_16d2_p2
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type1_16d2_p3
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type1_16d2_p4
	GROUP BY period
) t1

UNION ALL
SELECT 'B' AS trend_poly, period, count1, sum1, round((sum1::numeric/1e6)/14930.31419*100, 2) as per_agpe
FROM
(SELECT period, count(gid) AS count1, sum(st_area(st_transform(geom, 3347))) sum1
	FROM public.evi_poly_type2_16d2_p1
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type2_16d2_p2
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type2_16d2_p3
	GROUP BY period
UNION ALL
SELECT period, count(gid), sum(st_area(st_transform(geom, 3347)))
	FROM public.evi_poly_type2_16d2_p4
	GROUP BY period
) t2
ORDER BY 1, 2