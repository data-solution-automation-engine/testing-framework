# Design Pattern - Generic - Reconciliation

## Purpose
Ensuring the contents of two separate objects contain the same data, an assertion if two data sets are 100% equal.

An example is comparing a Dimension to a sample file that contains the expected structure and content.

## Motivation
Reconciliation checks are sometimes used as a means to automatically tests outputs against expected results, for example using a sample data set that must be reproduced like for like. Another use case is the comparison of data that is copied from one location to another.

## Structure
Using INTERSECT/EXCEPT

## Considerations and Consequences

The order of columns needs to be exactly the same for this pattern to work well.

## Example

`SELECT * FROM TABLE1 EXCEPT SELECT * FROM TABLE2`
