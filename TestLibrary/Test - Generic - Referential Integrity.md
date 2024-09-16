# Design Pattern - Generic - Referential Integrity

## Purpose
Ensuring that a database object that references another object (i.e. a 'child object') can correctly reference its parent object, so that referential integrity can be satisfied. 

An example is ensuring that a Data Vault Satellite can correctly reference its parent Hub table.

## Motivation
In typical relational database management systems (RDBMS), foreign key constraints will prevent data being entered that violates referential integrity. This is one of the ways the RDBMS protects the integrity, consistency, of the data. However, foreign keys may not necessarily be enforced or only be defined at logical level.

This happens often in data warehouse solutions. To facilitate parallel loading, and more generally avoid loading dependencies, foreign key references are not implemented. Even though a relationships between objects exists in the data model, this is not enforced by the database system. Instead, the correct definition of data logistics ('ETL') processes is intended to ensure that consistency is safeguarded. 

This is a way of implementing referential integrity, but as a validation *after* the data has been inserted and not as a prevention of data being entered in the first place. 

To use another Data Vault example, a Hub and Satellite have a relationship which dictates that the Satellite business key must also exist in the Hub table. However, it could happen that the Satellite is loaded before the Hub when both processes issue separate key distribution processes such as hash- or natural business keys.

Tests such as this one will ensure long-term consistency of the system, preventing errors that can could be caused by incorrect data logistics design.

## Structure
Performing a left-outer join or exists statement to asset of the parent key exists from the perspective of the child object.

## Considerations and consequences

Consistency can also be asserted by simply enabling a foreign key relationship. However, this also means loading dependencies are introduced which must be managed by the process orchestration. 

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