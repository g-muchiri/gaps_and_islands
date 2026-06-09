### WHEN TO USE CTEs

A question came up in my mind while doing random hackerrank questions,\
how do i know, simply by looking at the problem, that I need to use a CTE?\
I got three answers which I would like to document here as instances to use a CTE

1. If a question forces you to use a value before its calculated.
    This law however has a special exemption. If the value is generated from\
    sum() and Count(), there is a function called having that takes care of some of the problems.\

  Having sum()> x for example can be solved
2. If a Question requires that you filter the result of a window function
    Case in point. Find out all days where today's sales were lower than yesterday's sales
    CTE- calculate the lag
    Main query - filter the lag to negatives
3. When query requires you to aggregate an aggregation
    
