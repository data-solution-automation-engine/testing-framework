# Design Pattern - Data Vault - Satellite Referential Integrity

## Purpose
Ensuring a Data Vault Satellite can correctly reference its parent Hub table, so that referential integrity can be satisfied.

## Motivation
<explanation of what happens if it fails>

## Structure
Doing a left-outer join or EXISTS to see if the Hub key exists from the perspective of the Sat.

## Considerations and Consequences

Parallel loading...

## Example



`WITH recordcount AS 
(
  SELECT Count(*) AS Record_Count
  FROM   <Satellite>),testcount
     AS 
	    (
	     SELECT Count(*) AS test_Count
         FROM   <Satellite>
         WHERE  <key> NOT IN
		   (
		     SELECT <key>
             FROM <Hub>
		   )
		)
)
SELECT
   record_count
  ,test_count
  ,CASE
    WHEN test_count = 0 THEN 'Pass'
    ELSE 'Fail'
   END AS Status
  ,GETDATE()    AS Test_Execution_DateTime
  ,CURRENT_USER AS Test_Executor
FROM recordcount
LEFT OUTER JOIN testcount
ON 1 = 1; '`