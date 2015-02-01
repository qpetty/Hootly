CREATE DATABASE hootly;
use hootly;

CREATE TABLE Users (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   hootloot INT NOT NULL DEFAULT 100
);


CREATE TABLE Hoots (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   user_id INT NOT NULL,
   image_path TEXT NOT NULL,
   hoot_text CHAR(160) NOT NULL,
   hootloot INT NOT NULL DEFAULT 0,
   timestamp INT(11) NOT NULL,
   active BOOL DEFAULT 1,
   latitude FLOAT NOT NULL,
   longitude FLOAT NOT NULL
);

CREATE TABLE Hoots_Upvotes (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   hott_id INT NOT NULL,
   user_id INT NOT NULL,
   vote INT NOT NULL DEFAULT 1
);

CREATE TABLE Hoots_Downvotes (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   hoot_id INT NOT NULL,
   user_id INT NOT NULL,
   vote INT NOT NULL DEFAULT 1
);

CREATE TABLE Comments (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   user_id INT NOT NULL,
   post_id INT NOT NULL,
   hootloot INT NOT NULL DEFAULT 0,
   comment_text CHAR(160) NOT NULL
);

CREATE TABLE Comments_Upvotes (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   comment_id INT NOT NULL,
   user_id INT NOT NULL,
   vote INT NOT NULL DEFAULT 1
);

CREATE TABLE Comments_Downvotes (
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   comment_id INT NOT NULL,
   user_id INT NOT NULL,
   vote INT NOT NULL DEFAULT 1
);