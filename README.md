# PYTHON_SQL_P3_WALMART
Data Analysis Project 3  (Python) (SQL)

## 1. Background and Objective
This project builds a complete data analytics workflow—from pulling real-world data using the Kaggle API, preprocessing and performing EDA in Python, to solving business problems using SQL.<br>
We work with the Walmart 10K Sales dataset, analyze it in Python, and load it into MySQL/PostgreSQL for deeper query-based insights.<br>

### 🔍 Project Background
Modern retail businesses generate vast amounts of data. This project simulates a scenario where a data analyst is tasked with preparing and analyzing sales data from Walmart to derive actionable business insights.<br>
📊 Insights and recommendations are derived across:<br>
•	Sales Trends Analysis<br>
•	Category level performance<br>
•	Regional performance comparisons<br>
•	Customer behavior<br>
•	 payment preferences<br>

### 🎯 Objective
To build an end-to-end data analytics pipeline using Python and SQL:<br>
•	data extraction using Kaggle API<br>
•	Clean and transform the data<br>
•	Load into SQL databases<br>
•	Solve critical business problems with SQL -- The goal is to deliver actionable insights that support growth, efficiency, and data-driven decision-making.<br>
•	Prepare and publish the project with full documentation<br>


## 2. Problem Statement   
The business collects large volumes of sales and customer data across branches, cities, and categories, but key insights remain hidden. This analysis aims to uncover patterns in payment methods, sales performance, customer ratings, profitability, and revenue trends over time, while also addressing city-level behavior, branch comparisons, and data integrity issues.<br>


## 3. AIMS Grid
Aim:  Understand sales trends, performance, and customer behavior<br>
Inputs: Walmart sales dataset from Kaggle (~10K rows)<br>
Mechanism:	Python (EDA) → MySQL (Advance Analytics)<br>
Success:	Business questions answered with clear insights and documentation<br>


## 4. Data Sources
•	Dataset: Kaggle - Walmart 10K Sales Dataset<br>
•	Downloaded using: kaggle.exe datasets download -d najir0123/walmart-10k-sales-datasets<br>
•	File: Walmart.csv (~10,000 rows)<br>


## 5. Tools and Libraries
### Python Environment:<br>
- Jupyter Notebook / VS Code<br>
- Python 3.8+<br>
- Libraries:<br>
    • pandas<br>
    • sqlalchemy<br>
    • pymysql<br>
    • kaggle (API)<br>
### RDBMS/ database:<br>
- MySQL


## 6. ELT Pipeline (Extract, Load, Transform)

### Step-by-Step<br>
  1.	Extract → via Kaggle API<br>
  2.	Load → Unzip + load into Pandas<br>
  3.	Transform → Cleaning + Feature Engineering<br>

### 1. Extract & Load

This phase involves setting up the environment and retrieving the raw data.<br>

**• Objective:** To pull the raw data from its source into a working environment.
  - In terminal writing to download dataset –-  `kaggle datasets download -d najir0123/walmart-10k-sales-datasets` 
  - error : kaggle : The term 'kaggle' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again. 
  - Solved: `kaggle.exe datasets download -d najir0123/walmart-10k-sales-datasets`<br>

**• Environment Setup:** The process begins by configuring the system to allow script execution (`Set-ExecutionPolicy -Scope CurrentUser Unrestricted`), installing necessary tools like Jupyter Notebook and the Kaggle library, and troubleshooting command-line errors (e.g., using `kaggle.exe` instead of `kaggle`).<br>

**• Data Retrieval:** The Kaggle API is used to download the `walmart-10k-sales-datasets` dataset. The raw Walmart sales data, in a CSV file named Walmart.csv, is then loaded into a pandas DataFrame in a Jupyter Notebook in VS code. This initial load brings the data into the working memory of the Python environment.<br>

• `df = pd.read_csv('Walmart.csv', encoding_errors='ignore')` is used to read the file, with the `encoding_errors` parameter set to `'ignore'` to prevent errors from un-decodable characters.<br>
________________________________________
### 2. Transform
   
This is the core data cleaning and preprocessing stage, performed within the pandas DataFrame.<br>

**• Objective:** To clean the data by handling missing values, duplicates, and incorrect data types, and to create new features for analysis.<br>

**• Data Exploration:** Initial checks are performed using `df.shape`, `df.head()`, `df.describe()`, and `df.info()` to understand the data's structure, identify missing values, duplicates, and incorrect data types.<br>

**• Process:**
  - Duplicate Handling:  The `df.duplicated().sum()` command identifies 51 duplicate rows. These duplicates are removed using `df.drop_duplicates(inplace=True)`, which updates the DataFrame directly.<br>
  -	Missing Value Handling:  `df.isnull().sum()` is used to count missing values. Rows with missing data are dropped with `df.dropna(inplace=True)`. This action reduces the total number of rows from 10,000 to 9,969.<br>
  -	Data Type Conversion:  The unit_price column is initially of an object data type because it contains the $ symbol. To perform calculations, this column needs to be converted to a numerical type. The $ symbol is removed using `df['unit_price'].str.replace('$', '')` and then the column is converted to a float64 data type using `.astype(float)`.<br>
  -	Feature Engineering:  A new column named total is created by multiplying the unit_price and quantity columns `(df['total'] = df['unit_price'] * df['quantity'])`. This new column represents the total amount of each transaction and is crucial for sales analysis.<br>
  -	Final Check:  The `df.info()` and `df.shape` commands are used to verify that the transformations were successful, confirming that data types are correct and no more duplicates or missing values exist.<br>
________________________________________
### 3. Load (Final)
   
In this final step, the cleaned and transformed data is loaded into a persistent storage system for long-term use and analysis.<br>

**• Objective:** To export the cleaned and transformed data from the Python environment into a relational database for further analysis using SQL.<br>

**• Process:**
  - Dependencies:  The pymysql and SQLAlchemy libraries are imported. pymysql acts as an adapter, while SQLAlchemy's create_engine function provides a standardized way to connect to a MySQL database.<br>
  - Database Connection:  A connection engine is created to link Python to the MySQL database. The connection string is formatted as `mysql+pymysql://<username>:<password>@<host>:<port>/<database>`. Special characters in the password, like @, must be URL-encoded (%40).<br>
  - Data Loading:  The `df.to_sql()` method is used to export the DataFrame to a SQL table. The parameters `name='walmart'`, `con=engine_mysql`, and `if_exists='append'` are specified. This command creates a new table named walmart in the MySQL database and populates it with the cleaned data.<br>
  - Final Export:  As a final step, the cleaned data is also saved to a local CSV file named walmart_clean_data.csv using `df.to_csv('walmart_clean_data.csv', index=False)` as a backup.<br>


## 7. Data Structure Overview
<br>
<img width="227" height="374" alt="image" src="https://github.com/user-attachments/assets/685e6dd3-e018-48e6-bc77-9ebc3b90e3b0" />


## 8. SQL Analysis & Business Problem Solving  ( ADVANCE ANALYSIS )

- **Change-over-Time Analysis**
(Deals with trends, growth, increases/decreases across time)<BR>

Q8: Identify the 5 branches with the highest revenue decrease/increase ratio from 2022 → 2023<BR>
Q9: Total revenue in each year and month (Year-on-year and month-on-month revenue trends)<BR>
Q10: Maximum & minimum total revenue in each month of years (Seasonal highs and lows)<BR>
Q10.2: Maximum & minimum total profit_margin in each month of years<BR>
Q13: Moving Average of Daily Sales (7-day window) (Smoothing daily fluctuation to detect trends)<BR>
Q18: Total revenue from sales — all cities, quarter-wise and year-wise<BR>
Q20: Monthly sales growth — with percentage change<BR>

- **Cumulative Analysis**
(Tracking totals or running sums over time/entities)<BR>

Q14: Cumulative Customer Count by City

- **Performance Analysis**
(Comparing efficiency, profitability, quality, highs/lows, etc.)<BR>

Q2: Identify the highest-rated category in each branch + highest-rated overall<BR>
Q2.2: Highest-rated category count<BR>
Q3: Identify the busiest day for each branch based on number of transactions<BR>
Q4: Average, minimum, and maximum rating of categories for each city<BR>
Q5: Total profit for each category (ordered highest → lowest)<BR>
Q6: Most common payment method for each branch<BR>
Q10 & Q10.2 (also fit here since they evaluate max/min performance across time)<BR>
Q15: High vs Low-Rated Transactions<BR>
Q17: Revenue vs Profit Margin Matrix (Branch × Category)<BR>
Q19: Each city – avg sale per customer & avg rating per customer<BR>

- **Part-to-Whole Analysis**
(How pieces contribute to totals — proportions, shares, breakdowns)<BR>

Q1: Find different payment methods, number of transactions, and quantity sold by payment method<BR>

- **Data Segmentation**
(Slicing data into groups like city, branch, category, etc.)<BR>

Q7: Categorize sales into Morning, Afternoon, and Evening shifts<BR>
Q11: Top 5 cities with most orders in last 30 days<BR>
Q12: Finding duplicates — cities are 98 but branches are 100<BR>
Q21: Unique customer count per city<BR>

- **Reporting**
(Predefined summaries for business users)<BR>

Q16: Monthly Report Summary<BR>


## 9. Limitations
•	Data lacks timestamp granularity (no hour/minute info)<br>
•	Only 10,000 rows — not scalable for predictive modeling<br>
•	Missing customer demographic fields<br>
•	2019 data missing. Only 3 months data. 1st 3 or last 3<br>


## 10.Future Enhancements
•	Build Power BI/Tableau dashboards for visualization<br>
•	Add customer demographic data for advanced segmentation<br>
•	Automate the full pipeline using Airflow or Prefect<br>



