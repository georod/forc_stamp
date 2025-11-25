-- MODIS SInusoidal projection: to use or not to use?
-- 2024-11-06
-- Peter R.


-- This was taken from MODIS user guide but did not work.
-- https://lpdaac.usgs.gov/documents/101/MCD12_User_Guide_V6.pdf

INSERT INTO public.spatial_ref_sys(
	srid, auth_name, auth_srid, srtext, proj4text)
	VALUES (100001, 'Sinusoidal MODIS' , 100001, 'PROJCS["Sinusoidal", GEOGCS["GCS_unnamed ellipse",
DATUM["D_unknown", SPHEROID["Unknown",6371007.181,0]],
PRIMEM["Greenwich",0], UNIT["Degree",0.017453292519943295]],
PROJECTION["Sinusoidal"], PARAMETER["central_meridian",0],
PARAMETER["false_easting",0], PARAMETER["false_northing",0],UNIT["Meter",1]', 		
			'+proj=sinu +a=6371007.181 +b=6371007.181 +units=m');

-- Taken from QGIS but note that Peter already created srid=100000
INSERT INTO public.spatial_ref_sys(
	srid, auth_name, auth_srid, srtext, proj4text)
	VALUES (100002, 'Sinusoidal MODIS', 100002, 'PROJCRS["unknown",
    BASEGEOGCRS["GCS_unknown",
        DATUM["D_unknown",
            ELLIPSOID["unknown",6371007.181,0,
                LENGTHUNIT["metre",1,
                    ID["EPSG",9001]]]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["Degree",0.0174532925199433]]],
    CONVERSION["unnamed",
        METHOD["Sinusoidal"],
        PARAMETER["Longitude of natural origin",0,
            ANGLEUNIT["Degree",0.0174532925199433],
            ID["EPSG",8802]],
        PARAMETER["False easting",0,
            LENGTHUNIT["metre",1],
            ID["EPSG",8806]],
        PARAMETER["False northing",0,
            LENGTHUNIT["metre",1],
            ID["EPSG",8807]]],
    CS[Cartesian,2],
        AXIS["(E)",east,
            ORDER[1],
            LENGTHUNIT["metre",1,
                ID["EPSG",9001]]],
        AXIS["(N)",north,
            ORDER[2],
            LENGTHUNIT["metre",1,
                ID["EPSG",9001]]]]', 		
			'+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs +type=crs');
			

-- Jeffrey Evans discourages the uses of MODIS sinusoidal
-- https://gis.stackexchange.com/questions/39116/coordinate-system-of-a-modis-file-to-be-introduced-in-gdal-for-transformation
-- Jeffrey's proj4 string:	"+proj=sinu +R=6371007.181 +nadgrids=@null +wktext" 
