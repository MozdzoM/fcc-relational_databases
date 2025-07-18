create database worldcup;

create table teams(
    team_id serial not null primary key, 
    name varchar(20) not null unique
);

create table games(
    game_id serial not null primary key, 
    year int not null, round varchar(20) not null, 
    winner_id int not null references teams(team_id), 
    opponent_id int not null references teams(team_id), 
    winner_goals int not null, opponent_goals int not null
);
