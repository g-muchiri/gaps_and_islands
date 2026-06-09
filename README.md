# Gaps_and_Islands
This is a data engineering common logical Question used to identify consequtive sequences of data(Islands) and the gaps between them(Gaps)

Islands in this case are consecutive sequences of consequtive datapoints eg user logging in three days in a row.  
Gaps are the missing period between the islands like the times a user did not log in.

## Approach to solving the problem
At first we ran into data that had all the right fields but the user logged in once.  
After cleaning the data is when we discovered that the problem would change from how many times the user logged in  consecutively to how mmany days the system was in use back to back on a daily basis.

Even then, we discovered that There at no point was there a back to back daily login

We sought for different data and from it we were able to solve the problem

> [!TIP]
> There was heavy use of nested CTEs.

### Data description
The data had initially had 500 rows and two columns login date and client_id.\
We confirmed from Excel that there were a total of 20 client Ids with different login dates.\
This was a check we had ommitted previously and costed us alot of time only to redo the problem.\

### Data Cleaning
First step was remaning the columns to eliminate spaces and hence make easier to work with.

Next step was making use of REGEX expressions to clean the dates.\
>[!IMPORTANT]
>Here we had to scan through the table and see the format in which the dates were presented\
>so as to curate a REGEX around the dates

We found that the dates were in the following formats
 - DD/MM/YYYY
 - MM/DD/YY
 - YYYY/MM/DD
 - YYYY/DD/MM
After curating REGEX, we selected all data to confirm the integrity of the dates

### Use of CTE in the Phase of the actual problem solving
>[!NOTE]
>```SET datestyle = 'ISO, MDY'```
>is a useful command is in dates\
>It helps Postgres understand date formats that present differently than YYYY/MM/DD and hence no problems when converting a date to a date datatype

Since SQL forbids nesting window functions directly,\
In a case where the output of one window is directly required by another,\
Nested windows can be used which is the case in Gaps and Islands

#### Flow of thought
1. The first CTE would contain a lag of login dates partitioned by client ID to get\
   Client, date of login and the previous date of log in
   Here we would also create a row_number window function partitioned on client_id
2. The next step involved would be creating another column which would be `anchor`
    ```login_date - interval `1 day` * row_number```
   We figured out that if the login dates were consecutive the above code would produce the same date.\
   Say if first day of login which had row number 1 was 31st Dec 2026, subtracting a day from it would give \
   30th Dec 2026. If the second day of login with row number 2 was 1st January 2027, subtracting two days\
   from 1st January 2027 would still give us 30th Dec 2026
3. The final step would be finding the count of the anchor column and organising by descending to find out the longest streak

The longest streak was 2 from a client ID 17 who was the only one who seemed to have, just once, logged in back to back

[^1]: This problem was sourced from a conversation with Chat GPT wondering the cases in which one would use CTEs



