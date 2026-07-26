Netflix Content Analysis

A SQL-based data cleaning and exploratory analysis project on the Netflix titles dataset, with an accompanying Power BI dashboard.

Author: Srishti Dass Tools: MySQL / DBeaver, Power BI, Python (validation)
DASHBOARD PREVIEW 
1. <img width="1197" height="687" alt="image" src="https://github.com/user-attachments/assets/3245342e-5382-4c06-84a3-3e6385bdda81" />
2.<img width="1052" height="605" alt="image" src="https://github.com/user-attachments/assets/9b3f388f-c572-45e3-80ce-3bc4e421ea04" />



Project Structure
├── netflix_titles_clean.xlsx       # cleaned dataset (used for Power BI)
├── netflix_analysis.sql            # full cleaning + EDA script
├── README.md
└── screenshots/                    # dashboard page screenshots

Dataset

The dataset contains 8,807 unique Netflix titles (movies and TV shows) with fields for type, title, director, cast, country, date added to Netflix, release year, rating, duration, genre(s), and description.

🧹 Data Cleaning

Cleaning was done in MySQL and covered:

Step	Action	Why
Empty strings → NULL	NULLIF() on director, cast, country, rating, date_added	Empty strings don't behave like NULLs in aggregates/filters
Fill moderate-null columns	director, cast, country → 'Unknown'	These had too many missing values to drop without losing significant data
Drop sparse-null rows	Removed rows missing rating or date_added	Only ~14 rows affected — negligible impact on ~8,800-row dataset
Primary key	show_id set as primary key	Guaranteed unique per row
Additional data quality issues found during validation

Two issues weren't visible from the SQL script alone and are worth documenting for the report:

Duplicate rows from a prior export/import — the working file had ~8,993 duplicate rows (some byte-for-byte, some differing only in text encoding of special characters like em-dashes). Deduplicating on show_id brought the dataset from 17,786 rows down to the correct 8,793 unique rows.
Shifted rating/duration fields — 3 titles (all Louis C.K. specials) had their duration value sitting in the rating column (e.g., rating = "74 min") with duration left blank. Corrected by moving the value to duration and setting rating to Unknown.
 
 
 Key Findings : 

Content mix

Movies: 6,129 (69.7%)
TV Shows: 2,664 (30.3%)

Top genres (titles can belong to multiple genres)

Genre	Titles
International Movies	2,752
Dramas	2,426
Comedies	1,674
International TV Shows	1,349
Documentaries	869
Action & Adventure	859
TV Dramas	762
Independent Movies	756

Top countries producing content

Country	Titles
United States	3,684
India	1,046
United Kingdom	805
Canada	445
France	393
Japan	316
Spain	232
South Korea	231

Content added to Netflix by year — growth accelerated sharply from 2016, peaked in 2019 (2,016 titles added), then declined in 2020–2021 (dataset ends September 2021).

Maturity ratings — TV-MA (3,205) and TV-14 (2,157) dominate the catalog, together making up over 60% of titles — Netflix skews toward mature/teen audiences rather than family content.

Movie runtime trend — average movie length has steadily shortened, from ~120 minutes for 2002 releases to ~92 minutes for 2020 releases, a ~24% decline, consistent with the industry-wide shift toward shorter theatrical/streaming runtimes.

Most prolific directors — Rajiv Chilaka (19 titles, mostly kids' animated content), Raúl Campos & Jan Suter (18, stand-up specials), Marcus Raboy (16), Suhas Kadav (16).


How to Reproduce
Import the raw Netflix titles CSV into MySQL as netflix_titles
Run netflix_analysis.sql top to bottom
Export the cleaned table, or use netflix_titles_clean.xlsx directly
Load into Power BI to rebuild the dashboard visuals shown above
