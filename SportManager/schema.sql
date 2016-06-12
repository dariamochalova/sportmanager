create table athlete(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   firstname text,
   lastname text,    
   weight real,
   age int
);
create table gps_data(
	id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	exercise_id int,
	timestamp real,
	lat real,
	lon real,
	speed real
);
create table heart_data(
	id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	exercise_id int,
	timestamp real,
	length real
);
create table exercise(
	id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	athlete_id int,
	start_time real,
	end_time real,
	cal real,
	name text
);
create table users(
	id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	active int,
	login text,
	password text,
	athlete_id int
);