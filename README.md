# 3si-challenge

Asked by the 3SI team, here are my answers to the coding challenge questions.

## Question #1

What is the answer hidden in the dataset?

### Short Answer

WearYourMask!!

### Notes

- **Data Schema:** First, I downloaded and opened the file to get a sense of the data. I quickly skimmed through it and came up with this schema:

```
CREATE TABLE Q1 (
    id INT,
    col_1 DOUBLE,
    col_2 VARCHAR(100),
    col_3 DOUBLE,
    col_4 BIGINT,
    col_5 VARCHAR(100)
);
```

- Then loaded the table with data from the downloaded file.

```
LOAD DATA LOCAL INFILE 'path-to/prob1.txt'
INTO TABLE Q1
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';
```

- **Path to solution**: By quickly looking at the data, I realized that **col_2** and **col_5** were the main leads to the answer since they contained alphanumerical values. The first thing I did was look at the distinct values in these two columns. However, I should have kept going down this path. Instead, I wasted a lot of time on the weird spacing in the data of **col_5**, thinking the answer was hidden there in relation to other columns. Then I started looking at values and potential matches to words like "answer", "specific", "3si", "hidden", and "find". I noticed that the frequency of the word "Answer" was significantly higher than the other words. Eventually, I sorted **col_2** by the frequency of its distinct entries and found the answer.

```
mysql> SELECT col_2, COUNT(*) as freq FROM Q1 GROUP BY col_2 ORDER BY freq DESC limit 8;
+----------------+-------+
| col_2          | freq  |
+----------------+-------+
| The            | 80081 |
| Answer         | 70086 |
| You            | 60093 |
| Are            |  5082 |
| Looking        |  4000 |
| For            |  3084 |
| Is             |  2089 |
| WearYourMask!! |  1000 |
+----------------+-------+

```

## Question #2

What is the overlap in these tables?

### Short Answers

- \# of unique addresses:
  - HeadStart: 320
  - NCES: 2244
- \# of overlapping addresses: Depending on the definition of "overlapping," this could be as low as 19 or as high as 56 (using a relaxed, minimal definition).
- Query that includes everything from the HeadStart data and an indicator of whether there is a match in the NCES data:

```
SELECT
    hs.*,
    CASE
        WHEN nces.NCES_School_ID IS NOT NULL THEN 1 ELSE 0
    END AS is_match
FROM Q2_headstart hs
LEFT JOIN Q2_ncesdata nces
ON hs.city = nces.City
    AND hs.state = nces.State
    AND hs.name = nces.School_Name
    AND hs.county = nces.County_Name
```

### Notes

- I stored everything in the database tables as alphnumeric:

```
CREATE TABLE Q2_headstart (
    name varchar(50),
    typeString varchar(50),
    addressLineOne varchar(50),
    addressLineTwo varchar(50),
    city varchar(50),
    state varchar(50),
    zipFive varchar(50),
    zipFour varchar(50),
    county varchar(50),
    isPoBoxLocation Boolean,
    phone varchar(50),
    drivingDirectionsLink varchar(100),
    grantNumber varchar(50),
    delegateNumber varchar(50),
    programName varchar(50),
    programAddressLineOne varchar(50),
    programAddressLineTwo varchar(50),
    programCity	programState varchar(50),
    programZipFive varchar(50),
    programZipFour varchar(50),
    programCounty varchar(50),
    programPhone varchar(50),
    programRegistrationPhone varchar(50),
    latitude varchar(50),
    longitude varchar(50)
);

CREATE TABLE Q2_ncesdata (
    NCES_School_ID  varchar(50),
    State_School_ID  varchar(50),
    NCES_District_ID  varchar(50),
    State_District_ID  varchar(50),
    Low_Grade  varchar(50),
    High_Grade  varchar(50),
    School_Name  varchar(50),
    District varchar(50),
    County_Name varchar(50),
    Street_Address varchar(50),
    City varchar(50),
    State varchar(50),
    ZIP varchar(50),
    ZIP_4_digit varchar(50),
    Phone varchar(50),
    Locale_Code varchar(50),
    Locale varchar(50),
    Charter varchar(50),
    Magnet varchar(50),
    Title_I_School varchar(50),
    Title_I_School_Wide varchar(50),
    Students varchar(50),
    Teachers varchar(50),
    Student_Teacher_Ratio varchar(50),
    Free_Lunch varchar(50),
    Reduced_Lunch varchar(50)
);
```

- Here are the queries I used to get the unique addresses:

```
mysql> SELECT DISTINCT addressLineOne, addressLineTwo, city, state, zipFive, zipFour county FROM Q2_headstart;
...
320 rows in set (0.007 sec)

mysql> SELECT DISTINCT County_Name,Street_Address,City,State,ZIP,ZIP_4_digit FROM Q2_headstart;
...
2244 rows in set (0.007 sec)

```

- The concept of "overlapping" should be well-studied and clearly defined, as the two tables have different schemas and address formats. For example, the equivalence between `Street_Address` in NCES and `addressLineOne(+ addressLineTwo)` should be decided. Additionally, whether to consider four-digit ZIP code suffixes when determining address equivalence should also be clarified.
  Here is a query that uses a more restrictive definition of "overlap":

```
SELECT COUNT(*) AS overlapping_addresses
FROM (
    SELECT DISTINCT
       addressLineOne,
       addressLineTwo,
       city,
       state,
       zipFive,
       zipFour,
       county
    FROM Q2_headstart
    ) AS headstart
INNER JOIN (
      SELECT DISTINCT
        Street_Address,
        City,
        State,
        ZIP,
        ZIP_4_digit,
        County_Name
    FROM Q2_ncesdata
    ) AS ncesdata
ON headstart.addressLineOne = ncesdata.Street_Address
    AND headstart.city = ncesdata.City
    AND headstart.state = ncesdata.State
    AND headstart.zipFive = ncesdata.ZIP
    AND headstart.zipFour = ncesdata.ZIP_4_digit
    AND headstart.county = ncesdata.County_Name;
+-----------------------+
| overlapping_addresses |
+-----------------------+
|                    19 |
+-----------------------+
1 row in set (0.031 sec)
```

Here is a more relaxed version:

```
SELECT COUNT(*) AS overlapping_addresses
    FROM (
        SELECT DISTINCT
            addressLineOne,
            addressLineTwo,
            city,
            state,
            county
        FROM Q2_headstart
    ) AS headstart
    INNER JOIN (
        SELECT DISTINCT
            Street_Address,
            City,
            State,
            County_Name
        FROM Q2_ncesdata
    ) AS ncesdata
    ON headstart.addressLineOne = ncesdata.Street_Address
        AND headstart.city = ncesdata.City
        AND headstart.state = ncesdata.State
        AND headstart.county = ncesdata.County_Name;
+-----------------------+
| overlapping_addresses |
+-----------------------+
|                    52 |
+-----------------------+
1 row in set (0.031 sec)
```

- One way to improve this later is to compute an overlap score and flag potential overlaps with a score above a threshold.

- Here are the names of schools in HeadStart that have a match in NCES:

```

mysql> WITH JoinedData AS (
SELECT
    hs.\*,
    CASE
        WHEN nces.NCES_School_ID IS NOT NULL THEN 1 ELSE 0
    END AS is_match
FROM Q2_headstart hs
LEFT JOIN Q2_ncesdata nces
ON hs.city = nces.City
    AND hs.state = nces.State
    AND hs.name = nces.School_Name
    AND hs.county = nces.County_Name
)
SELECT JoinedData.name AS match_schools
    FROM JoinedData
WHERE is_match = 1;
+--------------------------------------+
| match_schools |
+--------------------------------------+
| Chase Lake Elementary |
| Lister |
| Larchmont |
| Franklin |
| Fern Hill |
| Downing |
| Birney |
| Edison |
| Geiger |
| Roosevelt |
| Whitman |
| McCarver |
| Mann |
| Manitou Park |
| Mary E. Theler Early Learning Center |
| Silver Beach Elementary School |
| Woodridge Elementary |
+--------------------------------------+
17 rows in set (0.033 sec)

```

## Question #3

Question 1 in Python.

### Short Answer

[Implementation of Question 1 in Python](q3/q1.py)

### Notes

Since I already knew the answer, I wrote a function to print the top N most frequent values of a column for a given CSV file. Although the code can be modified to automatically download and extract the file, I am reading the lines from a pre-downloaded and extracted file for the sake of time.

## Question #4

Top 50 records in the consolidated dataset (merged altogether), based on the number of occurrences.

### Answer

#### DuckDB

DuckDB is an in-process OLAP database optimized for analyzing big data. Its usage is straightforward, and the documentation is fairly good. I utilized it in my code to analyze the given data.

#### Prerequisites

The libraries duckdb, numpy, and pandas are assumed to be installed for this code to work.

#### Number of Ocurrances

According to the [documentation](https://meta.wikimedia.org/wiki/Research:Wikipedia_clickstream#Format), the last column (column3) is the number of occurrences of a (referrer, resource) pair. The code I wrote reads the data from a downloaded file; however, it can be modified to take a URL as input and download the data automatically.

```

python3 q4.py "<path_to_data>/clickstream-enwiki-2020-0\*.tsv.gz"
Loading...
Query...
column0 column1 column2 column3
0 other-empty Main*Page external 353532165
1 other-empty Main_Page external 313376698
2 other-empty Main_Page external 303567965
3 other-empty Main_Page external 280606527
4 other-empty Main_Page external 280049207
5 other-empty United_States_Senate external 145896151
6 other-empty Main_Page external 145385265
7 other-empty United_States_Senate external 132589145
8 other-empty United_States_Senate external 54234379
9 other-empty Hyphen-minus external 39576291
10 other-empty Hyphen-minus external 31344950
11 other-empty Hyphen-minus external 29289942
12 other-empty Hyphen-minus external 25339824
13 other-search Kobe_Bryant external 18687930
14 other-empty Hyphen-minus external 17283966
15 other-external Hyphen-minus external 17053938
16 other-empty Wikipedia external 13773564
17 other-internal Main_Page external 13278189
18 other-internal Main_Page external 12521477
19 other-internal Main_Page external 12441624
20 other-internal Main_Page external 11756793
21 other-search Sushant_Singh_Rajput external 11189214
22 other-internal Main_Page external 11129147
23 other-external Hyphen-minus external 11053884
24 other-search 2019–20_coronavirus_pandemic external 10653762
25 other-external Hyphen-minus external 10220623
26 other-empty 2019–20_coronavirus_pandemic external 9985625
27 other-external Hyphen-minus external 9589778
28 other-external Hyphen-minus external 9033903
29 other-empty Media external 8166954
30 other-internal Main_Page external 7676422
31 other-empty Tasuku_Honjo external 7402774
32 other-search Spanish_flu external 6329327
33 other-search Coronavirus external 6285604
34 other-search Aaron_Hernandez external 6251814
35 other-empty COVID-19_pandemic external 6071600
36 other-search Parasite*(2019_film) external 6053931
37 other-search Coronavirus external 5964543
38 other-empty Bible external 5661729
39 other-search Killing_of_George_Floyd external 5579711
40 other-search 2020_coronavirus_pandemic_in_India external 5510389
41 other-search Michael_Jordan external 5426823
42 other-search Irrfan_Khan external 5144147
43 other-empty Bible external 4953655
44 other-search Elon_Musk external 4895253
45 other-search Laptop external 4571860
46 other-search Kim_Jong-un external 4492336
47 other-search COVID-19_pandemic external 4456335
48 other-search Joe_Exotic external 4436577
49 other-search Death_of_George_Floyd external 4260458
Execution Time: 24.52 seconds`

```
