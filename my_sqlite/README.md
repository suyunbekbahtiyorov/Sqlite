# Welcome to My Sqlite
***

## Task
Welcome to My Sqlite

## Description
My sqlite exercise is working with databases. In this project you can use "SELECT || INSERT || UPDATE || DELETE || FROM" commands.
Constructor It will be prototyped:
def initialize

From Implement a from method which must be present on each request. From will take a parameter and it will be the name of the table. (technically a table_name is also a filename (.csv))
It will be prototyped:

def from(table_name)

Select Implement a where method which will take one argument a string OR an array of string. It will continue to build the request. During the run() you will collect on the result only the columns sent as parameters to select :-).
It will be prototyped:

def select(column_name)
OR
def select([column_name_a, column_name_b])

Where Implement a where method which will take 2 arguments: column_name and value. It will continue to build the request. During the run() you will filter the result which match the value.
It will be prototyped:

def where(column_name, criteria)

Join Implement a join method which will load another filename_db and will join both database on a on column.
It will be prototyped:

def join(column_on_db_a, filename_db_b, column_on_db_b)

Order Implement an order method which will received two parameters, order (:asc or :desc) and column_name. It will sort depending on the order base on the column_name.
It will be prototyped:

def order(order, column_name)

Insert Implement a method to insert which will receive a table name (filename). It will continue to build the request.
def insert(table_name)

Values Implement a method to values which will receive data. (a hash of data on format (key => value)). It will continue to build the request. During the run() you do the insert.
def values(data)

Update Implement a method to update which will receive a table name (filename). It will continue to build the request. An update request might be associated with a where request.
def update(table_name)

Set Implement a method to update which will receive data (a hash of data on format (key => value)). It will perform the update of attributes on all matching row. An update request might be associated with a where request.
def set(data)

Delete Implement a delete method. It set the request to delete on all matching row. It will continue to build the request. An delete request might be associated with a where request.
def delete

Run Implement a run method and it will execute the request.
Part 01
Create a program which will be a Command Line Interface (CLI) to your MySqlite class.
It will use readline and we will run it with ruby my_sqlite_cli.rb.

It will accept request with:

SELECT|INSERT|UPDATE|DELETE
FROM
WHERE (max 1 condition)
JOIN ON (max 1 condition) Note, you can have multiple WHERE. Yes, you should save and load the database from a file. :-)
** Example 00 ** (Ruby)

## Installation
ruby

## Usage
```
ruby my_cli.rb

my_cli> SELECT * FROM nba_player_data.csv

my_cli> INSERT INTO nba_player_data.csv VALUES ('Suyunbek Bakhtiyorov','2005','0905','F', '5-9', '200','september 5', 2005','7 School')

my_cli> SELECT year_start, position FROM nba_player_data.csv WHERE year_start = 1991

my_cli> UPDATE nba_player_data.csv SET height='20',weight='500'WHERE name ='Suyunbek Bakhtiyorov'

my_cli> DELETE FROM nba_player_data.csv WHERE name = 'Suyunbek Bakhtiyorov'

```

### The Core Team


<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
<span><img alt='Qwasar SV -- Software Engineering School's Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px'></span>
