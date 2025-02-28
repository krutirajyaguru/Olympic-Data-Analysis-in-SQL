# Olympic-Data-Analysis-in-SQL
SQL Practice

Install postgressql in MAC
- Download postgres.app from postgres website (I downloaded Universal Version 15)
- Install it
- Move it to applications folder
- Run some commands on Terminal
    - sudo mkdir -p /etc/paths.d && echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/Postgres app 
    - psql --version
    - postgres -VARCHAR
- Open PostgreSQL 15 from applications
- server settings -> start
- Try psql command to check if it is working or not
=====================================================
- Create olympic.sql file with 'create table' query
- open terminal on the file location
    - command: psql -h localhost -U postgres -p 5432
                -> CREATE DATABASE olympic; (Inside postgres User)
                
                1. First Method for CREATE TABLE and INSERT data:
                    - \c olympic (connect to database)
                    - CREATE TABLE tablename...COMMAND
                    - COPY tablename FROM 'filepath/filename.csv' DELIMITER ',' CSV HEADER; (copy csv data to database table)
                    - SELECT * FROM tablename LIMIT 5; (TO check inserted data)
                    - \q (exit psql)
                2. Second Method for CREATE TABLE and INSERT data:
                    - \q (exit psql)
                    - psql -h localhost -U postgres -p 5432 -d olympic -f olympicDB.sql 
                3. Third Method for CREATE TABLE and INSERT data:
                    - open Terminal
                    - touch filepath/filename.sql (To create a file)
                    - nano/less/man filepath/filename.sql (To edit file
                    , write sql queries here)
                    - psql -h localhost -U postgres -p 5432 -d olympic -f filepath/filename.sql

=====================================================
INSIDE OF PSQL
\l - list all databases
\d - list all tables inside the current database
\c nameofdatabase - connect to a database
\q - quit psql
CREATE DATABASE nameofdatabase;
DROP DATABASE nameofdatabase;
CREATE TABLE nameoftable (col1 INT, col2 VARCHAR...);
DROP TABLE nameoftable;

=====================================================
dump from postgres to local file
    - pg_dump -h localhost -U postgres -p 5432 -d olympic > filename.sql (filepath/filename.sql)
