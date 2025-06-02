CREATE TABLE Q1 ( 
    id INT, 
    val_1 DOUBLE, 
    val_2 VARCHAR(100), 
    val_3 DOUBLE, 
    val_4 BIGINT, 
    val_5 VARCHAR(100)
);

LOAD DATA LOCAL INFILE 'path-to/prob1.txt' 
INTO TABLE Q1 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n';

mysql> SELECT col_2, COUNT(*) as freq FROM Q1 GROUP BY col_2 ORDER BY freq DESC limit 8;
-- +----------------+-------+
-- | col_2          | freq  |
-- +----------------+-------+
-- | The            | 80081 |
-- | Answer         | 70086 |
-- | You            | 60093 |
-- | Are            |  5082 |
-- | Looking        |  4000 |
-- | For            |  3084 |
-- | Is             |  2089 |
-- | WearYourMask!! |  1000 |
-- +----------------+-------+