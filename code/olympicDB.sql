DROP TABLE nocregions;
CREATE TABLE nocregions (
    NOC	VARCHAR,
    region VARCHAR,
    notes VARCHAR
);
COPY nocregions FROM '/Users/SQLpractice/data/OlympicHistory/noc_regions.csv' DELIMITER ',' CSV HEADER;

DROP TABLE athleteevents;
CREATE TABLE athleteevents (
    
    ID INT,
    Name VARCHAR,
    Sex VARCHAR,
    Age VARCHAR,
    Height VARCHAR,
    Weight VARCHAR,
    Team VARCHAR,
    NOC VARCHAR,
    Games VARCHAR,
    Year INT,
    Season VARCHAR,
    City VARCHAR,
    Sport VARCHAR,
    Event VARCHAR,
    Medal VARCHAR

);
COPY athleteevents FROM '/Users/SQLpractice/data/OlympicHistory/athlete_events.csv' DELIMITER ',' CSV HEADER;
