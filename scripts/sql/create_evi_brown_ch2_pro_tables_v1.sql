-- =============================================
-- Link change polygon table with portected area
-- =============================================
-- 2025-01-28
-- Peter R.
-- PhD Thesis, Chapter 3

-- Browning Change 1
CREATE TABLE evi_brown_ch2_level2_int_v2 AS
SELECT row_number() OVER () AS rowid, t3.*
FROM
(SELECT t1.gid, t1.patches, t1.period, t1.level2, t2.gid AS gid_pro, t2.gid0 AS gid0_pro, t2.status, St_Multi((ST_DUMP(st_intersection(t1.geom, t2.geom))).geom)::geometry(MultiPolygon,100000) AS geom
FROM
evi_brown_ch2_level2_v1 t1
LEFT JOIN
(SELECT gid, __gid as gid0, 'protected' AS status, st_transform(geom, 100000) geom FROM cpcad_dec2020_clipped2) t2
ON ST_Intersects(t1.geom, t2.geom)) t3
;

-- ALTER TABLE evi_brown_ch2_level2_v2 RENAME TO evi_brown_ch2_level2_int_v2;

COMMENT ON TABLE evi_brown_ch2_level2_int_v2 IS 'EVI browning trend polygon changes (level 2) in Change 2 (period 2 vs. period 3) with protected area status. Rowid is now fixed. [2025-01-28]';


ALTER TABLE evi_brown_ch2_level2_int_v2 ADD CONSTRAINT evi_brown_ch2_level2_int_v2_pkey PRIMARY KEY (rowid);

--ALTER TABLE evi_brown_ch2_level2_v2 DROP CONSTRAINT evi_brown_ch2_level2_v2_pkey;


-- DROP INDEX IF EXISTS evi_brown_ch2_level2_v2_geom_idx;

CREATE INDEX IF NOT EXISTS evi_brown_ch2_level2_int_v2_geom_idx
    ON public.evi_brown_ch2_level2_int_v2 USING gist
    (geom)
    TABLESPACE pg_default;


---
CREATE TABLE evi_brown_ch2_level2_diff_v2 AS
SELECT row_number() OVER () AS rowid, t3.*
FROM
(SELECT t1.gid, t1.patches, t1.period, t1.level2, t2.gid AS gid_pro, t2.gid0 AS gid0_pro, t2.status, St_Multi((ST_DUMP(st_difference(t1.geom, t2.geom))).geom)::geometry(MultiPolygon,100000) AS geom
FROM
evi_brown_ch2_level2_v1 t1
LEFT JOIN
(SELECT gid, __gid as gid0, 'non-protected' AS status, st_transform(geom, 100000) geom FROM cpcad_dec2020_clipped2) t2
ON ST_Intersects(t1.geom, t2.geom)) t3
;

COMMENT ON TABLE evi_brown_ch2_level2_diff_v2 IS 'EVI browning trend polygon changes (level 2) in period 2008-2012 that intersect protected area polygons but are not fully contained. These polygons are technically not protected. Rowid is now fixed (as to opposed to those in views). [2025-01-28]';


ALTER TABLE evi_brown_ch2_level2_diff_v2 ADD CONSTRAINT evi_brown_ch2_level2_diff_v2_pkey PRIMARY KEY (rowid);


-- DROP INDEX IF EXISTS public.evi_green_ch2_inter_v1_geom_idx;

CREATE INDEX IF NOT EXISTS evi_brown_ch2_level2_diff_v2_geom_idx
    ON public.evi_brown_ch2_level2_diff_v2 USING gist
    (geom)
    TABLESPACE pg_default;
	
---

CREATE TABLE evi_brown_ch2_level2_not_int_v2 AS
SELECT row_number() OVER () AS rowid, t3.*
FROM
(SELECT t1.gid, t1.patches, t1.period, t1.level2, t2.gid AS gid_pro, t2.gid0 AS gid0_pro, 'non-protected' AS status, t1.geom::geometry(MultiPolygon,100000) AS geom
FROM
evi_brown_ch2_level2_v1 t1
LEFT JOIN
(SELECT gid, __gid as gid0, 'non-protected' AS status, st_transform(geom, 100000) geom FROM cpcad_dec2020_clipped2) t2
ON ST_Intersects(t1.geom, t2.geom)
WHERE t2.gid is null) t3
;

COMMENT ON TABLE evi_brown_ch2_level2_not_int_v2 IS 'EVI browning trend polygon changes (level 2) in period 2008-2012 that do not intersect protected area polygons. These polygons not protected. Rowid is now fixed (as to opposed to those in views). [2025-01-28]';


ALTER TABLE evi_brown_ch2_level2_not_int_v2 ADD CONSTRAINT evi_brown_ch2_level2_not_int_v2_pkey PRIMARY KEY (rowid);


-- DROP INDEX IF EXISTS public.evi_green_ch2_inter_v1_geom_idx;

CREATE INDEX IF NOT EXISTS evi_brown_ch2_level2_not_int_v2_geom_idx
    ON public.evi_brown_ch2_level2_not_int_v2 USING gist
    (geom)
    TABLESPACE pg_default;
	
--select * from evi_brown_ch2_level2_not_int_v2	
