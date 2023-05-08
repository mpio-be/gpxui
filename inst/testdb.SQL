
USE tests;

CREATE TABLE GPS_POINTS (
  gps_id int(2) NOT NULL        COMMENT 'gps id',
  gps_point int(10) NOT NULL    COMMENT 'gps point',
  datetime_ datetime NOT NULL   COMMENT 'gps date-time (AKDT)',
  lat double NOT NULL           COMMENT 'latitude',
  lon double NOT NULL           COMMENT 'longitude',
  ele double NOT NULL           COMMENT 'elevation',
  pk int(10) NOT NULL           AUTO_INCREMENT,
  PRIMARY KEY (pk),
  KEY gps (gps_id,gps_point),
  KEY datetime_ (datetime_)
) ENGINE=ARIA;

CREATE TABLE GPS_TRACKS (
  gps_id int(2) NOT NULL        COMMENT 'gps id',
  seg_id int(10) NOT NULL       COMMENT 'segment id',
  seg_point_id int(10) NOT NULL COMMENT 'segment point id',
  datetime_ datetime NOT NULL   COMMENT 'gps date-time (AKDT)',
  lat double NOT NULL           COMMENT 'latitude',
  lon double NOT NULL           COMMENT 'longitude',
  ele float NOT NULL            COMMENT 'elevation',
  pk int(10) NOT NULL           AUTO_INCREMENT,
  PRIMARY KEY (pk),
  KEY gps (gps_id,seg_id),
  KEY datetime_ (datetime_)
) ENGINE=ARIA;


CREATE OR REPLACE VIEW mid_points AS
SELECT gps_id as gps_id_centre, avg(lat) lat, avg(lon) lon
FROM
    GPS_POINTS
GROUP BY gps_id; 

CREATE OR REPLACE VIEW mid_tracks AS
SELECT gps_id as gps_id_centre, avg(lat) lat, avg(lon) lon
FROM
    GPS_TRACKS
GROUP BY gps_id