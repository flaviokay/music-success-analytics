USE music_success_analytics;

TRUNCATE TABLE fact_tracks;

LOAD DATA LOCAL INFILE 'C:/Users/Admin/Desktop/music-success-analytics-notebooks/sql_exports/fact_tracks.csv'
INTO TABLE fact_tracks
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

USE music_success_analytics;

SELECT 'dim_artists' AS table_name, COUNT(*) AS total_rows FROM dim_artists
UNION ALL
SELECT 'dim_albums' AS table_name, COUNT(*) AS total_rows FROM dim_albums
UNION ALL
SELECT 'dim_genres' AS table_name, COUNT(*) AS total_rows FROM dim_genres
UNION ALL
SELECT 'dim_countries' AS table_name, COUNT(*) AS total_rows FROM dim_countries
UNION ALL
SELECT 'dim_labels' AS table_name, COUNT(*) AS total_rows FROM dim_labels
UNION ALL
SELECT 'fact_tracks' AS table_name, COUNT(*) AS total_rows FROM fact_tracks;

USE music_success_analytics;

SELECT *
FROM dim_labels
ORDER BY label_id;

USE music_success_analytics;

SELECT 
    SUM(CASE WHEN a.artist_id IS NULL THEN 1 ELSE 0 END) AS missing_artists,
    SUM(CASE WHEN al.album_id IS NULL THEN 1 ELSE 0 END) AS missing_albums,
    SUM(CASE WHEN g.genre_id IS NULL THEN 1 ELSE 0 END) AS missing_genres,
    SUM(CASE WHEN c.country_id IS NULL THEN 1 ELSE 0 END) AS missing_countries,
    SUM(CASE WHEN l.label_id IS NULL THEN 1 ELSE 0 END) AS missing_labels
FROM fact_tracks f
LEFT JOIN dim_artists a ON f.artist_id = a.artist_id
LEFT JOIN dim_albums al ON f.album_id = al.album_id
LEFT JOIN dim_genres g ON f.genre_id = g.genre_id
LEFT JOIN dim_countries c ON f.country_id = c.country_id
LEFT JOIN dim_labels l ON f.label_id = l.label_id;

-- 1. Genre performance analysis
-- This query analyzes music performance by genre, comparing track volume,
-- total streams, average streams and average popularity.

USE music_success_analytics;

SELECT
    g.genre,
    COUNT(f.track_id) AS total_tracks,
    SUM(f.stream_count) AS total_streams,
    ROUND(AVG(f.stream_count), 0) AS avg_streams,
    ROUND(AVG(f.popularity), 2) AS avg_popularity
FROM fact_tracks f
JOIN dim_genres g 
    ON f.genre_id = g.genre_id
GROUP BY g.genre
ORDER BY total_streams DESC;

-- Query 2: Hit rate by genre
-- This query calculates the percentage of hit tracks for each genre.
-- It helps identify which genres are more likely to produce successful tracks.

SELECT
    g.genre,
    COUNT(f.track_id) AS total_tracks,
    SUM(f.is_hit) AS total_hits,
    ROUND(SUM(f.is_hit) / COUNT(f.track_id) * 100, 2) AS hit_rate_percentage,
    ROUND(AVG(f.stream_count), 0) AS avg_streams,
    ROUND(AVG(f.popularity), 2) AS avg_popularity
FROM fact_tracks f
JOIN dim_genres g
    ON f.genre_id = g.genre_id
GROUP BY g.genre
ORDER BY hit_rate_percentage DESC;

-- Query 3: Top countries by average streams
-- This query analyzes music performance by country.
-- It ranks countries based on average stream count per track.

SELECT
    c.country,
    COUNT(f.track_id) AS total_tracks,
    SUM(f.stream_count) AS total_streams,
    ROUND(AVG(f.stream_count), 0) AS avg_streams,
    ROUND(AVG(f.popularity), 2) AS avg_popularity,
    ROUND(SUM(f.is_hit) / COUNT(f.track_id) * 100, 2) AS hit_rate_percentage
FROM fact_tracks f
JOIN dim_countries c
    ON f.country_id = c.country_id
GROUP BY c.country
ORDER BY avg_streams DESC;

-- Query 4: Independent vs label-backed performance
-- This query compares independent tracks with label-backed tracks.
-- It evaluates track volume, average streams, average popularity and hit rate.

SELECT
    l.label_type,
    COUNT(f.track_id) AS total_tracks,
    SUM(f.stream_count) AS total_streams,
    ROUND(AVG(f.stream_count), 0) AS avg_streams,
    ROUND(AVG(f.popularity), 2) AS avg_popularity,
    ROUND(SUM(f.is_hit) / COUNT(f.track_id) * 100, 2) AS hit_rate_percentage
FROM fact_tracks f
JOIN dim_labels l
    ON f.label_id = l.label_id
GROUP BY l.label_type
ORDER BY avg_streams DESC;

-- Query 5: Top labels by average streams
-- This query compares individual labels by track volume, average streams,
-- average popularity and hit rate.

SELECT
    l.label,
    l.label_type,
    COUNT(f.track_id) AS total_tracks,
    SUM(f.stream_count) AS total_streams,
    ROUND(AVG(f.stream_count), 0) AS avg_streams,
    ROUND(AVG(f.popularity), 2) AS avg_popularity,
    ROUND(SUM(f.is_hit) / COUNT(f.track_id) * 100, 2) AS hit_rate_percentage
FROM fact_tracks f
JOIN dim_labels l
    ON f.label_id = l.label_id
GROUP BY l.label, l.label_type
ORDER BY avg_streams DESC;

-- Query 6: Audio features comparison between hit and non-hit tracks
-- This query compares hit and non-hit tracks across popularity, streams,
-- danceability, energy, instrumentalness, tempo, duration and explicit rate.

SELECT
    CASE
        WHEN f.is_hit = 1 THEN 'Hit'
        ELSE 'Non-Hit'
    END AS track_type,
    COUNT(f.track_id) AS total_tracks,
    ROUND(AVG(f.popularity), 2) AS avg_popularity,
    ROUND(AVG(f.stream_count), 0) AS avg_streams,
    ROUND(AVG(f.danceability), 2) AS avg_danceability,
    ROUND(AVG(f.energy), 2) AS avg_energy,
    ROUND(AVG(f.instrumentalness), 2) AS avg_instrumentalness,
    ROUND(AVG(f.tempo), 2) AS avg_tempo,
    ROUND(AVG(f.duration_min), 2) AS avg_duration_min,
    ROUND(AVG(f.explicit) * 100, 2) AS explicit_rate_percentage
FROM fact_tracks f
GROUP BY f.is_hit
ORDER BY f.is_hit;

-- Query 7: Explicit vs non-explicit track performance
-- This query compares explicit and non-explicit tracks across streams,
-- popularity and hit rate.

SELECT
    CASE
        WHEN f.explicit = 1 THEN 'Explicit'
        ELSE 'Non-Explicit'
    END AS explicit_type,
    COUNT(f.track_id) AS total_tracks,
    SUM(f.stream_count) AS total_streams,
    ROUND(AVG(f.stream_count), 0) AS avg_streams,
    ROUND(AVG(f.popularity), 2) AS avg_popularity,
    ROUND(SUM(f.is_hit) / COUNT(f.track_id) * 100, 2) AS hit_rate_percentage
FROM fact_tracks f
GROUP BY f.explicit
ORDER BY avg_streams DESC;

-- Query 8: Release year performance trend
-- This query analyzes track volume, average streams, average popularity
-- and hit rate by release year.

SELECT
    f.release_year,
    COUNT(f.track_id) AS total_tracks,
    SUM(f.stream_count) AS total_streams,
    ROUND(AVG(f.stream_count), 0) AS avg_streams,
    ROUND(AVG(f.popularity), 2) AS avg_popularity,
    ROUND(SUM(f.is_hit) / COUNT(f.track_id) * 100, 2) AS hit_rate_percentage
FROM fact_tracks f
GROUP BY f.release_year
ORDER BY f.release_year;

-- Query 9: Top 20 tracks by stream count
-- This query retrieves the top-performing tracks by stream count,
-- including artist, genre, country and label information.

SELECT
    f.track_id,
    f.track_name,
    a.artist_name,
    g.genre,
    c.country,
    l.label,
    l.label_type,
    f.release_year,
    f.popularity,
    f.stream_count
FROM fact_tracks f
JOIN dim_artists a
    ON f.artist_id = a.artist_id
JOIN dim_genres g
    ON f.genre_id = g.genre_id
JOIN dim_countries c
    ON f.country_id = c.country_id
JOIN dim_labels l
    ON f.label_id = l.label_id
ORDER BY f.stream_count DESC
LIMIT 20;

-- Query 10: Country performance analysis
-- This query compares countries by number of tracks, total streams,
-- average streams, average popularity and hit rate.

SELECT
    c.country,
    COUNT(f.track_id) AS total_tracks,
    SUM(f.stream_count) AS total_streams,
    ROUND(AVG(f.stream_count), 0) AS avg_streams,
    ROUND(AVG(f.popularity), 2) AS avg_popularity,
    ROUND(AVG(f.is_hit) * 100, 2) AS hit_rate
FROM fact_tracks f
JOIN dim_countries c 
    ON f.country_id = c.country_id
GROUP BY c.country
ORDER BY avg_streams DESC;

-- Query 11: Best performing genres by country
-- This query compares genre performance within each country,
-- using total tracks, average streams, average popularity and hit rate.

SELECT
    c.country,
    g.genre,
    COUNT(f.track_id) AS total_tracks,
    SUM(f.stream_count) AS total_streams,
    ROUND(AVG(f.stream_count), 0) AS avg_streams,
    ROUND(AVG(f.popularity), 2) AS avg_popularity,
    ROUND(AVG(f.is_hit) * 100, 2) AS hit_rate
FROM fact_tracks f
JOIN dim_countries c
    ON f.country_id = c.country_id
JOIN dim_genres g
    ON f.genre_id = g.genre_id
GROUP BY c.country, g.genre
ORDER BY c.country, avg_streams DESC;

-- Query 12: Top 20 artists by total stream count
-- This query identifies the artists with the highest total stream count in the dataset.
-- It also compares number of tracks, average streams, average popularity and hit rate.

USE music_success_analytics;

SELECT
    a.artist_name,
    COUNT(f.track_id) AS total_tracks,
    SUM(f.stream_count) AS total_streams,
    ROUND(AVG(f.stream_count), 0) AS avg_streams,
    ROUND(AVG(f.popularity), 2) AS avg_popularity,
    ROUND(AVG(f.is_hit) * 100, 2) AS hit_rate
FROM fact_tracks f
JOIN dim_artists a 
    ON f.artist_id = a.artist_id
GROUP BY a.artist_name
ORDER BY total_streams DESC
LIMIT 20;