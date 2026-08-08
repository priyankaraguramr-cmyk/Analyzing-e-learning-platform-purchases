# Analyzing-e-learning-platform-purchases using mysql
MySQL Module Capstone Project 
Overview:
This project designs, populates, and queries a relational MySQL database for an e-learning platform.
It analyzes learner purchase behavior, course popularity, and category performance using joins, aggregations,
subqueries, CTEs, CASE expressions, NULL handling, and a database view.
Repository Contents

File	Description:
Elearning_analysis.sql	
Complete MySQL script: database & table creation, sample data inserts, join queries, 
all 12 analytical queries (Q1–Q12), subqueries, CTEs, CASE, NULL handling, 
the category_performance_view.

DA_V8_Summary_Report.docx	One-page summary report with key insights and recommendations derived from the query output.
screenshots/	Folder containing result screenshots for each query, numbered to match the sections below.

Requirements:

●MySQL 8.0+ or MySQL Workbench connected to a MySQL 8.0+ server (required for the WITH
clause / CTE syntax used in Q9 and Q10).

●No external dependencies - the script is plain SQL and runs in any standard MySQL client.

How to Run
1. Open elearning_analysis.sql in MySQL Workbench (or any MySQL client).

2. Execute the full script top to bottom, or run it section by section (recommended for capturing individual query screenshots).
mysql -u <username> -p < elearning_analysis.sql

3. The script drops and recreates the elearning_platform database on each run, so it is safe to re-execute.

Database Schema
learners:
Column	Type	Notes:
learner_id	INT, PK, AUTO_INCREMENT	Unique learner identifier
full_name	VARCHAR(100)	Learner name
country	VARCHAR(50)	Country of residence
courses

Column	Type	Notes:
course_id	INT, PK, AUTO_INCREMENT	Unique course identifier
course_name	VARCHAR(100)	Course title
category	VARCHAR(50)	Course category
unit_price	DECIMAL(10,2)	Price per course

purchases:
Column	Type	Notes:
purchase_id	INT, PK, AUTO_INCREMENT	Unique purchase identifier
learner_id	INT, FK → learners	References the purchasing learner
course_id	INT, FK → courses	References the purchased course
quantity	INT	Number of units purchased
purchase_date	DATE	Date of purchase

Sample Data
●5 learners across 4 countries (USA, India, Italy, Japan)

●6 courses across 5 categories (Beginner, Data Science, Marketing,
Web Development, Design)

●7 purchase records — one course (UX Design Basics) is intentionally left 
unpurchased to demonstrate NULL-handling and never-purchased-course queries

Queries Included:
Query	Description:
Q1	Each learner's total spending with their country

Q2	Top 3 most purchased courses by quantity

Q3	Each category's total revenue and number of unique learners

Q4	Learners who purchased from more than one category

Q5	Courses never purchased

Q6	Learners whose total spending is above the average learner spending (subquery)

Q7	Courses priced higher than any course in the Beginner category (ANY subquery

Q8	Learners who spent more than the average spending in their own country (correlated subquery)

Q9	CTE: total spending per learner, filtered to those above 10,000

Q10	CASE: classify learners as High / Medium / Low Value by spending

Q11	NULL handling: replace missing purchase counts with 0 using IFNULL/COALESCE

Q12	View: category_performance_view showing revenue, purchase count, and average revenue per purchase

Key Findings:
●Total platform revenue across all purchases: INR 44,385.00
●Web Development and Data Science are the highest-revenue categories, together contributing over 73% of total revenue
●Python for Beginners is the most purchased course by volume
●Kenji Sato is the top-spending learner (High Value tier); 3 of 5 learners purchased across more than one category
●UX Design Basics recorded zero purchases

Full insights and recommendations are in DA_V8_Summary_Report.docx.
Screenshots
The screenshots/ folder contains one image per query result, matching the section headings in elearning_analysis.sql: 
database & table creation, sample data, INNER/LEFT/RIGHT joins, and Q1 through Q12.
Notes
●This script has been tested end-to-end and executes without errors.
●Q9 and Q10 use the WITH clause (CTE), which requires MySQL 8.0 or later.
●The database is dropped and recreated at the start of the script (DROP DATABASE IF EXISTS), so re-running it will
not cause duplicate-key errors.
