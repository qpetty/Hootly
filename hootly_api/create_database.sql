CREATE DATABASE hootly;
use hootly;

CREATE TABLE Users (
   id CHAR(42) NOT NULL PRIMARY KEY,
   hootloot INT NOT NULL DEFAULT 100,
   last_notification INT(11) NOT NULL DEFAULT 0,
   device_type VARCHAR(7),
   notifications INT NOT NULL DEFAULT 0,
   device_token VARCHAR(256)
);


CREATE TABLE Hoots (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   user_id CHAR(42) NOT NULL,
   image_path TEXT NOT NULL,
   hoot_text CHAR(160) NOT NULL,
   hootloot INT NOT NULL DEFAULT 0,
   votes INT NOT NULL DEFAULT 0,
   timestamp INT(11) NOT NULL,
   active BOOL NOT NULL DEFAULT 1,
   latitude FLOAT NOT NULL,
   longitude FLOAT NOT NULL
);

CREATE TABLE Hoots_Upvotes (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   hoot_id INT NOT NULL,
   user_id CHAR(42) NOT NULL,
   vote INT NOT NULL DEFAULT 1
);

CREATE TABLE Hoots_Downvotes (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   hoot_id INT NOT NULL,
   user_id CHAR(42) NOT NULL,
   vote INT NOT NULL DEFAULT 1
);

CREATE TABLE Comments (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   user_id CHAR(42) NOT NULL,
   post_id INT NOT NULL,
   hootloot INT NOT NULL DEFAULT 0,
   votes INT NOT NULL DEFAULT 0,
   timestamp INT(11) NOT NULL,
   active BOOL DEFAULT 1,
   comment_text CHAR(160) NOT NULL
);

CREATE TABLE Comments_Upvotes (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   comment_id INT NOT NULL,
   user_id CHAR(42) NOT NULL,
   vote INT NOT NULL DEFAULT 1
);

CREATE TABLE Comments_Downvotes (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   comment_id INT NOT NULL,
   user_id CHAR(42) NOT NULL,
   vote INT NOT NULL DEFAULT 1
);
