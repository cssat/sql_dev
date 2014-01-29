--drop  table ospi.FederalEthRace_dim

create table ospi.FederalEthRace_dim
(FederalEthRaceID int not null,
 FederalEthRace varchar(100)
 , primary key (FederalEthRaceID))
 
 insert into ospi.FederalEthRace_dim
 select 1,'American Indian-Alaskan Native' union
 select 2,'Asian' union
 select 3,'Black-African American' union
 select 4,'Hispanic-Latino' union
 select 5,'White' union
 select 6,'Hawaiian-Pacific Islander' union
 select 7,'Multi-Racial' union
 select 8,'Not Provided' 
 
 

