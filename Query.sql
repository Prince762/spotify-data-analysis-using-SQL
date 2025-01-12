select * from spotify..music

use spotify

-- EDA

--  number of rows

select count(*) from spotify..music

-- number of artists

select count(distinct artist) from spotify..music

-- number of albums

select count( distinct album) from spotify..music

-- types of albums

select distinct album_type from spotify..music

-- maximum and minimum duration for a track

select max(duration_min) from spotify..music

select min(duration_min) from spotify..music

-- types of channels

select distinct channel from music

-- platform 

select distinct most_playedon from music


-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------------------------

-- Retrieve the names of all tracks that have more than 1 billion streams.

select * from music
where stream > 1000000000

-- List all albums along with their respective artists.


select distinct album, artist from music

-- Get the total number of comments for tracks where licensed = TRUE.

select sum(comments) total_comments from music
where licensed = 1

-- Find all tracks that belong to the album type single.

select track , album_type from music
where album_type = 'single'

-- Count the total number of tracks by each artist.


select artist, count(track) no_of_tracks from music
group by artist

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculate the average danceability of tracks in each album.

select album, avg(danceability) avg_danceability from music
group by album
order by avg_danceability desc


-- Find the top 5 tracks with the highest energy values.

select top 5 track, max(energy) en from music
group by Track
order by en desc

-- List all tracks along with their views and likes where official_video = TRUE

select  track, sum(Views) total_views, sum(Likes) total_likes from music
where official_video  = 1
group by Track
order by total_views desc


-- For each album, calculate the total views of all associated tracks.

select album,track, sum(views) total_views from music
group by album, Track
order by total_views desc

-- Retrieve the track names that have been streamed on Spotify more than YouTube.

select * from (
select track, 
coalesce(sum(case when most_playedon = 'Spotify' then stream end),0) as streamed_on_spotify,
coalesce(sum(case when most_playedon = 'Youtube' then stream end),0) as streamed_on_youtube
from music
group by Track
) as t1
where t1.streamed_on_spotify > t1.streamed_on_youtube
and streamed_on_youtube <> 0


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Find the top 3 most-viewed tracks for each artist using window functions.

with ranking_artist  -- CTE
as(
select  Artist,Track,SUM(views) total_views ,
DENSE_RANK() over(partition by artist order by sum(views) desc) as rank  --RANK
from music
group by Artist,Track) 
select * from ranking_artist
where rank <= 3
order by Artist, total_views desc


-- Write a query to find tracks where the liveness score is above the average.

select  avg(liveness) from music -- avg is 0.19

select * from music
where Liveness > 0.19

-- OR

select Track,Artist,Liveness from music
where liveness > (select avg(liveness) from music)  -- we write the query for comparison in case data is ever changed



-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

with cte as(
select Album,
MAX(energy) as highest_energy,
MIN(energy) as lowest_energy
from music
group by Album)
select album,
highest_energy - lowest_energy as energy_difference
from cte

order by energy_difference desc


-- Find tracks where the energy-to-liveness ratio is greater than 1.2

select Track, Energy/Liveness as en_liv_ratio from music
where Energy/Liveness >1.2

-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

select * from music


select track, SUM(likes) over(order by views) as total_likes from music 
order by total_likes desc;