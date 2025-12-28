# Cronometer CSV to SQL Server Loader

## Features

- T-SQL ETL for Cronometer CSV exports.
- Load official Cronometer exports into SQL Server.
- Handles 100+ nutrition fields (macros, micros, aminos).
- BULK INSERT for speed.
- Custom Queries to analyze your data in an environment you are familiar with!
- Full-refresh of the tables from your Cronometer exports.

## Preparation

- In Cronometer, navigate to and download your desired `.csv` files from the accounts page into `C:\exports\cronometer\` (**ensure you have NO conflict there such as that folder already being used!**)
- You will need download SQL Server Management Studio and then spin up a SQL Server database to house your exported Cronometer data. Name it `Cronometer` if you like.

## Setup

- You will need to run `create_alter_loading_procedures.sql` on your newly-created, personal Cronometer database.
	- This will create (or update) the procedures on your database. It **will not run them**.
- In order to run your procecures and load your Cronometer data into your personal database, go to the Usage section.

## Usage

- Run `EXEC dbo.Load_All_Cronometer_Data @base_path = 'C:\exports\cronometer\';`
	- This will load all of your Cronometer data into your database.
	- **WARNING** It WILL drop these tables before it does so as this is a FULL WIPE/REFRESH of these tables in order to get the most accurate data from your Cronometer exports.