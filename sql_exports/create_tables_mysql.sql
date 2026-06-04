
CREATE DATABASE IF NOT EXISTS music_success_analytics;
USE music_success_analytics;

DROP TABLE IF EXISTS fact_tracks;
DROP TABLE IF EXISTS dim_artists;
DROP TABLE IF EXISTS dim_albums;
DROP TABLE IF EXISTS dim_genres;
DROP TABLE IF EXISTS dim_countries;
DROP TABLE IF EXISTS dim_labels;

CREATE TABLE dim_artists (
    artist_id INT PRIMARY KEY,
    artist_name VARCHAR(255)
);

CREATE TABLE dim_albums (
    album_id INT PRIMARY KEY,
    album_name VARCHAR(255)
);

CREATE TABLE dim_genres (
    genre_id INT PRIMARY KEY,
    genre VARCHAR(100)
);

CREATE TABLE dim_countries (
    country_id INT PRIMARY KEY,
    country VARCHAR(100)
);

CREATE TABLE dim_labels (
    label_id INT PRIMARY KEY,
    label VARCHAR(255),
    label_type VARCHAR(50)
);

CREATE TABLE fact_tracks (
    track_id VARCHAR(50) PRIMARY KEY,
    track_name VARCHAR(255),
    artist_id INT,
    album_id INT,
    genre_id INT,
    country_id INT,
    label_id INT,
    release_date DATE,
    release_year INT,
    duration_ms INT,
    duration_min DECIMAL(6,2),
    popularity INT,
    is_hit INT,
    danceability DECIMAL(5,3),
    energy DECIMAL(5,3),
    `key` INT,
    loudness DECIMAL(6,2),
    mode INT,
    instrumentalness DECIMAL(5,3),
    tempo DECIMAL(6,2),
    stream_count BIGINT,
    explicit INT,
    FOREIGN KEY (artist_id) REFERENCES dim_artists(artist_id),
    FOREIGN KEY (album_id) REFERENCES dim_albums(album_id),
    FOREIGN KEY (genre_id) REFERENCES dim_genres(genre_id),
    FOREIGN KEY (country_id) REFERENCES dim_countries(country_id),
    FOREIGN KEY (label_id) REFERENCES dim_labels(label_id)
);
