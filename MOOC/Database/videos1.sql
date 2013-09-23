DROP TABLE IF EXISTS video_labels;
DROP TABLE IF EXISTS video_events;
DROP TABLE IF EXISTS label_type;
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS event_type;
DROP TABLE IF EXISTS detector;
DROP TABLE IF EXISTS lane_type;
DROP TABLE IF EXISTS detector_type;
DROP TABLE IF EXISTS video_detector_assoc;
DROP TABLE IF EXISTS detector_file;
DROP TABLE IF EXISTS video;
DROP TABLE IF EXISTS geo_coords;
DROP TABLE IF EXISTS detector;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS mount_type;
DROP TABLE IF EXISTS road_type;
DROP TABLE IF EXISTS street;
DROP TABLE IF EXISTS road_condition;

CREATE TABLE road_condition (
	type varchar(16),
	PRIMARY KEY(type));

insert into road_condition values ("wet");
insert into road_condition values ("dry");
insert into road_condition values ("snowy");

CREATE TABLE street (
   id int NOT NULL AUTO_INCREMENT,
	street_name varchar(32),
	PRIMARY KEY(id));

insert into street(street_name) values ("Snelling Ave.");
insert into street(street_name) values ("University Ave.");
insert into street(street_name) values ("Spruce Tree Dr.");
insert into street(street_name) values ("Ocean Cir.");
insert into street(street_name) values ("La Palma Ave.");
insert into street(street_name) values ("Tubbs Rd.");
insert into street(street_name) values ("Crescent Lake Rd.");
insert into street(street_name) values ("Maple Grove Pkwy.");
insert into street(street_name) values ("Hospital Dr.");
insert into street(street_name) values ("Fish Lake Rd.");
insert into street(street_name) values ("Sycamore Ln.");
insert into street(street_name) values ("Unknown Rd.");

CREATE TABLE road_type (
	type ENUM('intersection','tunnel','freeway') DEFAULT "intersection",
	PRIMARY KEY(type));

insert into road_type values ("intersection");
insert into road_type values ("tunnel");
insert into road_type values ("freeway");

CREATE TABLE mount_type (
	type varchar(16),
	PRIMARY KEY(type));

insert into mount_type values ("luminaire");
insert into mount_type values ("mast arm");
insert into mount_type values ("overhead");
insert into mount_type values ("standard");
insert into mount_type values ("non-standard");

CREATE TABLE location (
   id int NOT NULL AUTO_INCREMENT,
	city varchar(32) NOT NULL,
	state varchar(32) NOT NULL,
	country varchar(32) NOT NULL,
   PRIMARY KEY(id));

insert into location(city,state,country) values("St. Paul","MN","USA");
insert into location(city,state,country) values("Anaheim","CA","USA");
insert into location(city,state,country) values("Waterford","MI","USA");
insert into location(city,state,country) values("Maple Grove","MN","USA");
insert into location(city,state,country) values("Westminster","CO","USA");

CREATE TABLE geo_coords (
   id int NOT NULL AUTO_INCREMENT,
	lat real NOT NULL,
	lon real NOT NULL,
	PRIMARY KEY(id));

insert into geo_coords(lat,lon) values (44.955759,-93.167037);
insert into geo_coords(lat,lon) values (44.954798,-93.167083);
insert into geo_coords(lat,lon) values (33.853212,-117.849108);
insert into geo_coords(lat,lon) values (42.667718,-83.386615);
insert into geo_coords(lat,lon) values (45.131811,-93.477731);
insert into geo_coords(lat,lon) values (45.079449,-93.442948);

CREATE TABLE video (
	video_id int NOT NULL AUTO_INCREMENT,
	filename varchar(32),
	weather varchar(32),
	TOD_start varchar(16),
	duration int,
	mount_type varchar(16),
	loc_id int,
	geo_id int,
	camera_height int,
	road_type varchar(16),
	main_street int,
	cross_street int,
	road_direction varchar(4),
	traffic_direction varchar(16) DEFAULT "approaching",
	PRIMARY KEY(video_id),
   FOREIGN KEY (weather) REFERENCES road_condition(type),
   FOREIGN KEY(loc_id) REFERENCES location (id),
   FOREIGN KEY(geo_id) REFERENCES geo_coords (id),
	FOREIGN KEY(main_street) REFERENCES street (id),
	FOREIGN KEY(cross_street) REFERENCES street (id));

insert into video(filename,weather,TOD_start,duration,mount_type,loc_id,geo_id,road_type,main_street,cross_street)
   values ("M2U00234.MPG","dry","day",2143,"luminaire",2,3,"intersection",5,4);
insert into video(filename,weather,TOD_start,duration,mount_type,loc_id,geo_id,road_type,main_street,cross_street)
   values ("M2U00347.MPG","dry","day",3155,"luminaire",4,6,"intersection",8,9);
insert into video(filename,weather,TOD_start,duration,mount_type,loc_id,geo_id,road_type,main_street,cross_street)
   values ("M2U00236.MPG","wet","transition",3213,"luminaire",1,2,"intersection",1,3);
insert into video(filename,weather,TOD_start,duration,mount_type,loc_id,geo_id,road_type,main_street,cross_street)
   values ("M2U00025.MPG","dry","night",1843,"luminaire",1,2,"intersection",1,3);
insert into video(filename,weather,TOD_start,duration,mount_type,loc_id,geo_id,road_type,main_street,cross_street)
   values ("M2U00237.MPG","wet","night",3236,"luminaire",1,2,"intersection",1,3);
insert into video(filename,weather,TOD_start,duration,mount_type,loc_id,geo_id,road_type,main_street,cross_street)
   values ("M2U00328.MPG","dry","day",3206,"mast arm",5,4,"intersection",12,12);
insert into video(filename,weather,TOD_start,duration,mount_type,loc_id,geo_id,road_type,main_street,cross_street)
   values ("M2U00342.MPG","wet","day",3206,"mast arm",5,4,"intersection",12,12);
insert into video(filename,weather,TOD_start,duration,mount_type,loc_id,geo_id,road_type,main_street,cross_street)
   values ("M2U00341.MPG","dry","transition",3206,"mast arm",5,4,"intersection",12,12);
insert into video(filename,weather,TOD_start,duration,mount_type,loc_id,geo_id,road_type,main_street,cross_street)
   values ("M2U00329.MPG","wet","transition",3206,"mast arm",5,4,"intersection",12,12);
insert into video(filename,weather,TOD_start,duration,mount_type,loc_id,geo_id,road_type,main_street,cross_street)
   values ("M2U00331.MPG","dry","night",3206,"mast arm",5,4,"intersection",12,12);
insert into video(filename,weather,TOD_start,duration,mount_type,loc_id,geo_id,road_type,main_street,cross_street)
   values ("M2U00234.MPG","wet","night",3206,"mast arm",5,4,"intersection",12,12);

CREATE TABLE detector_file (
	id int AUTO_INCREMENT,
	PRIMARY KEY(id));

insert into detector_file(id) values (1);
insert into detector_file(id) values (2);
insert into detector_file(id) values (3);
insert into detector_file(id) values (4);
insert into detector_file(id) values (5);
insert into detector_file(id) values (6);

CREATE TABLE detector_type (
	id int AUTO_INCREMENT,
	det_type varchar(20) NOT NULL,
	PRIMARY KEY(id));

insert into detector_type(det_type) values ("presence");
insert into detector_type(det_type) values ("stop line");
insert into detector_type(det_type) values ("pedestrian/debris");
insert into detector_type(det_type) values ("smoke");
insert into detector_type(det_type) values ("tunnel lane");
insert into detector_type(det_type) values ("function(pitchfork)");

CREATE TABLE lane_type (
	type varchar(8) DEFAULT "thru",
	PRIMARY KEY(type));

insert into lane_type values ("thru");
insert into lane_type values ("lt");
insert into lane_type values ("rt");
insert into lane_type values ("thru/lt");
insert into lane_type values ("thru/rt");
insert into lane_type values ("lt/rt");
insert into lane_type values ("all");

CREATE TABLE detector (
	detector_id  int AUTO_INCREMENT,
	detector_file_id int,
	det_num int,
	detector_type int,
	lane_type varchar(8),
	PRIMARY KEY(detector_id),
	FOREIGN KEY(detector_file_id) REFERENCES detector_file (id),
	FOREIGN KEY(detector_type) REFERENCES detector_type (id),
	FOREIGN KEY(lane_type) REFERENCES lane_type (type));

insert into detector(detector_file_id,det_num,detector_type,lane_type) values (1,109,6,"thru/rt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (1,114,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (1,119,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (1,124,6,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (1,129,2,"thru/rt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (1,132,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (1,135,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (1,138,2,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (2,106,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (2,111,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (2,116,6,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (2,121,6,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (2,126,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (2,129,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (2,132,2,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (2,135,2,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (3,114,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (3,119,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (3,124,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (3,109,6,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (3,129,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (3,132,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (3,135,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (3,138,2,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (4,114,6,"thru/rt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (4,119,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (4,124,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (4,109,6,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (4,129,2,"thru/rt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (4,132,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (4,135,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (4,138,2,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (5,114,6,"thru/rt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (5,119,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (5,124,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (5,109,6,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (5,129,2,"thru/rt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (5,132,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (5,135,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (5,138,2,"lt");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (6,106,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (6,111,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (6,116,6,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (6,121,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (6,124,2,"thru");
insert into detector(detector_file_id,det_num,detector_type,lane_type) values (6,127,2,"thru");

CREATE TABLE event_type (
	type varchar(20),
	PRIMARY KEY(type));

insert into event_type values("pedestrian");
insert into event_type values("debris");
insert into event_type values("smoke");
insert into event_type values("low contrast");
insert into event_type values("presence");
insert into event_type values("stopped vehicle");

CREATE TABLE results (
	results_id int AUTO_INCREMENT,
	event_type varchar(8),
	detector_id int,
   video_id int,
	version_num varchar(16) NOT NULL,
	tp_tot int NOT NULL,
	tp_g int,
	fp_tot int NOT NULL,
	fp_g int,
	fn_tot int NOT NULL,
	fn_g int,
	PRIMARY KEY(results_id),
	FOREIGN KEY(event_type) REFERENCES event_type (type),
	FOREIGN KEY(detector_id) REFERENCES detector (detector_id));

insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",1,1,"9.7.3.0",161,145,0,0,7,7);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",2,1,"9.7.3.0",114,97,1,1,3,3);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",3,1,"9.7.3.0",151,133,1,1,3,3);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",4,1,"9.7.3.0",30,26,0,0,19,19);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",5,1,"9.7.3.0",159,144,2,1,6,5);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",6,1,"9.7.3.0",110,94,5,4,3,2);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",7,1,"9.7.3.0",147,130,5,4,4,3);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",8,1,"9.7.3.0",31,27,5,4,13,11);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",9,2,"9.7.3.0",116,105,0,0,1,1);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",10,2,"9.7.3.0",127,116,1,1,2,2);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",11,2,"9.7.3.0",40,34,1,1,7,7);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",12,2,"9.7.3.0",44,42,0,0,2,2);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",13,2,"9.7.3.0",108,99,8,6,8,6);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",14,2,"9.7.3.0",122,114,6,3,10,7);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",15,2,"9.7.3.0",35,30,6,5,25,24);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",16,2,"9.7.3.0",52,49,3,2,6,4);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",17,3,"9.7.3.0",60,51,3,0,3,2);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",18,3,"9.7.3.0",73,62,2,1,29,29);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",19,3,"9.7.3.0",58,50,1,0,6,5);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",20,3,"9.7.3.0",8,6,0,0,15,14);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",21,3,"9.7.3.0",57,48,6,3,6,5);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",22,3,"9.7.3.0",72,61,3,2,8,8);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",23,3,"9.7.3.0",57,49,2,1,5,3);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",24,3,"9.7.3.0",8,6,0,0,2,1);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",25,4,"9.7.3.0",48,30,6,5,8,7);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",26,4,"9.7.3.0",74,60,5,1,5,5);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",27,4,"9.7.3.0",72,57,2,1,6,6);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",28,4,"9.7.3.0",6,4,1,1,8,8);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",29,4,"9.7.3.0",47,29,7,6,2,2);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",30,4,"9.7.3.0",73,59,6,2,3,3);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",31,4,"9.7.3.0",70,55,4,3,4,3);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",32,4,"9.7.3.0",8,5,1,1,20,15);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",33,5,"9.7.3.0",85,58,7,5,45,43);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",34,5,"9.7.3.0",139,111,6,2,75,72);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",35,5,"9.7.3.0",141,112,10,4,15,13);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",36,5,"9.7.3.0",14,12,0,0,8,5);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",37,5,"9.7.3.0",84,57,8,6,24,24);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",38,5,"9.7.3.0",140,112,5,1,15,13);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",39,5,"9.7.3.0",138,109,13,7,11,10);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",40,5,"9.7.3.0",14,12,2,1,4,4);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",41,6,"9.7.3.0",52,26,1,1,4,4);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",42,6,"9.7.3.0",96,62,0,0,1,1);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",43,6,"9.7.3.0",79,46,0,0,0,0);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",44,6,"9.7.3.0",51,25,2,2,11,10);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",45,6,"9.7.3.0",94,60,2,2,3,3);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",46,6,"9.7.3.0",79,46,0,0,3,3);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",41,7,"9.7.3.0",11,0,0,0,16,16);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",42,7,"9.7.3.0",72,42,0,0,5,5);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",43,7,"9.7.3.0",59,28,0,0,0,0);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",44,7,"9.7.3.0",11,0,0,0,3,3);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",45,7,"9.7.3.0",71,42,1,0,1,1);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",46,7,"9.7.3.0",55,27,4,1,2,1);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",41,8,"9.7.3.0",1,0,0,0,47,47);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",42,8,"9.7.3.0",50,25,0,0,15,15);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",43,8,"9.7.3.0",40,22,0,0,23,23);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",44,8,"9.7.3.0",1,0,1,0,34,25);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",45,8,"9.7.3.0",47,24,3,1,12,9);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",46,8,"9.7.3.0",37,21,3,1,16,10);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",41,9,"9.7.3.0",25,10,0,0,16,13);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",42,9,"9.7.3.0",77,39,1,0,2,2);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",43,9,"9.7.3.0",96,56,1,0,4,3);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",44,9,"9.7.3.0",25,10,0,0,3,3);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",45,9,"9.7.3.0",74,37,4,2,8,7);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",46,9,"9.7.3.0",93,54,4,2,2,1);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",41,10,"9.7.3.0",10,2,0,0,48,39);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",42,10,"9.7.3.0",47,28,1,0,7,4);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",43,10,"9.7.3.0",44,24,3,1,16,12);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",44,10,"9.7.3.0",10,2,0,0,27,24);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",45,10,"9.7.3.0",47,28,1,0,8,8);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",46,10,"9.7.3.0",43,24,4,1,5,4);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",41,11,"9.7.3.0",1,1,0,0,72,54);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",42,11,"9.7.3.0",51,24,2,1,18,15);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",43,11,"9.7.3.0",27,13,3,0,10,8);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",44,11,"9.7.3.0",1,1,0,0,48,37);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",45,11,"9.7.3.0",47,21,6,4,9,8);
insert into results(event_type,detector_id,video_id,version_num,tp_tot,tp_g,fp_tot,fp_g,fn_tot,fn_g)
   values ("presence",46,11,"9.7.3.0",27,13,3,0,9,7);

CREATE TABLE label_type (
	type varchar(16),
	PRIMARY KEY(type));

CREATE TABLE video_events (
	video_id  int NOT NULL,
	event_type  varchar(8) NOT NULL,
	FOREIGN KEY(video_id) REFERENCES Video (video_id),
	FOREIGN KEY(event_type) REFERENCES event_type (type));

CREATE TABLE video_labels (
	video_id  int NOT NULL,
	label_type  varchar(16) NOT NULL,
	FOREIGN KEY(video_id) REFERENCES Video (video_id),
	FOREIGN KEY(label_type) REFERENCES label_type (type));



select det_type,mount_type,TOD_start,weather,lane_type,version_num,
sum(tp_tot)/(sum(tp_tot)+sum(fp_tot)) as ptot,1-sum(tp_tot)/(sum(tp_tot)+sum(fn_tot)) as rtot,2*sum(tp_tot)/(2*sum(tp_tot)+sum(fp_tot)+sum(fn_tot)) as fscore,
sum(tp_g)/(sum(tp_g)+sum(fp_g)) as pgr,1-sum(tp_g)/(sum(tp_g)+sum(fn_g)) as rgr,2*sum(tp_g)/(2*sum(tp_g)+sum(fp_g)+sum(fn_g)) as fgr,
(sum(tp_tot)-sum(tp_g))/(sum(tp_tot)+sum(fp_tot)-sum(tp_g)-sum(fp_g)) as pred,1-(sum(tp_tot)-sum(tp_g))/(sum(tp_tot)+sum(fn_tot)-sum(tp_g)-sum(fn_g)) as rred,2*(sum(tp_tot)-sum(tp_g))/(2*(sum(tp_tot)-sum(tp_g))+sum(fp_tot)+sum(fn_tot)-sum(fp_g)-sum(fn_g)) as fred
from video,detector_file,detector,detector_type,results
where video.video_id=results.video_id and detector.detector_file_id=detector_file.id and results.detector_id=detector.detector_id and detector.detector_type=detector_type.id
group by det_type,mount_type,TOD_start,weather,lane_type with rollup;

select filename,det_type,mount_type,TOD_start,weather,version_num,
sum(tp_tot)/(sum(tp_tot)+sum(fp_tot)) as ptot,1-sum(tp_tot)/(sum(tp_tot)+sum(fn_tot)) as rtot,2*sum(tp_tot)/(2*sum(tp_tot)+sum(fp_tot)+sum(fn_tot)) as fscore,
sum(tp_g)/(sum(tp_g)+sum(fp_g)) as pgr,1-sum(tp_g)/(sum(tp_g)+sum(fn_g)) as rgr,2*sum(tp_g)/(2*sum(tp_g)+sum(fp_g)+sum(fn_g)) as fgr,
(sum(tp_tot)-sum(tp_g))/(sum(tp_tot)+sum(fp_tot)-sum(tp_g)-sum(fp_g)) as pred,1-(sum(tp_tot)-sum(tp_g))/(sum(tp_tot)+sum(fn_tot)-sum(tp_g)-sum(fn_g)) as rred,2*(sum(tp_tot)-sum(tp_g))/(2*(sum(tp_tot)-sum(tp_g))+sum(fp_tot)+sum(fn_tot)-sum(fp_g)-sum(fn_g)) as fred
from video,detector_file,detector,detector_type,results
where video.video_id=results.video_id and detector.detector_file_id=detector_file.id and results.detector_id=detector.detector_id and detector.detector_type=detector_type.id
group by filename,det_type;

select *,
tp_tot/(tp_tot+fp_tot) as ptot,1-tp_tot/(tp_tot+fn_tot) as rtot,2*tp_tot/(2*tp_tot+fp_tot+fn_tot) as fscore,
tp_g/(tp_g+fp_g) as pgr,1-tp_g/(tp_g+fn_g) as rgr,2*tp_g/(2*tp_g+fp_g+fn_g) as fgr,
(tp_tot-tp_g)/(tp_tot+fp_tot-tp_g-fp_g) as pred,1-(tp_tot-tp_g)/(tp_tot+fn_tot-tp_g-fn_g) as rred,2*(tp_tot-tp_g)/(2*(tp_tot-tp_g)+fp_tot+fn_tot-fp_g-fn_g) as fred
from video,detector_file,detector,detector_type,results
where video.video_id=results.video_id and detector.detector_file_id=detector_file.id and results.detector_id=detector.detector_id and detector.detector_type=detector_type.id
order by video.video_id;
