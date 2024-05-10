-------------------------------------------------------------------- CUSTOMER  DEMOGRAPHICS ---------------------------------------------------------------


--Top 5 Customers in terms of  Purchase Amount ($) during Festival Season--
Use chocolate_sales;
Select * from (Select a.Customer_Name,a.Sales,DENSE_RANK() over(order by a.Sales desc) as rnk from(
SELECT 
    cd.Customer_Name,
    SUM(pd.cost * sft.quantity_sold) as 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
        INNER JOIN
    customer_dimension cd ON cd.customer_id = sft.customer_id
    where  monthname(str_to_date(sft.date,'%m/%d/%Y')) in ('October','November','December')
GROUP BY cd.Customer_Name)a) b
where b.rnk <6

--===================================================
--Top 5 Customers in terms of Purchase Amount ($)--

Use chocolate_sales;
Select * from (Select a.Customer_Name,a.Sales,DENSE_RANK() over(order by a.Sales desc) as rnk from(
SELECT 
    cd.Customer_Name,
    SUM(pd.cost * sft.quantity_sold) as 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
        INNER JOIN
    customer_dimension cd ON cd.customer_id = sft.customer_id
    GROUP BY cd.Customer_Name)a) b
where b.rnk <6

--===================================================

--Total Purchase ($) - Gender-wise--

Use chocolate_sales;
SELECT 
    cd.gender,
    SUM(pd.cost * sft.quantity_sold) / (SELECT 
            SUM(pd.cost * sft.quantity_sold)
        FROM
            product_dimension pd
                INNER JOIN
            sales_fact_table sft ON sft.product_id = pd.product_id) * 100 AS 'Percent_Share'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
        INNER JOIN
    customer_dimension cd ON cd.customer_id = sft.customer_id
GROUP BY cd.gender


--======================================================
--Total Purchase ($) by Age Group--
Use chocolate_sales;

SELECT 
    CASE
        WHEN Age > 50 THEN 'Old Age'
        WHEN Age > 30 THEN 'Middle Age'
        ELSE 'Young Age'
    END AS 'Generation',
    sum(a.Purchase) as 'Purchase'
FROM
    (SELECT 
        TIMESTAMPDIFF(YEAR, STR_TO_DATE(cd.DOB, '%d-%M-%Y'), CURDATE()) AS Age,
            SUM(pd.cost * sft.quantity_sold) AS 'Purchase'
    FROM
        product_dimension pd
    INNER JOIN sales_fact_table sft ON sft.product_id = pd.product_id
    INNER JOIN customer_dimension cd ON cd.customer_id = sft.customer_id
    GROUP BY Age) a
GROUP BY Generation
Order by Purchase desc

--=========================================================
--Total Purchase ($) by Loyalty Status--
Use chocolate_sales;

SELECT 
    cd.Loyalty_Status,
    SUM(pd.cost * sft.quantity_sold) / (SELECT 
            MAX(purchase)
        FROM
            (SELECT 
                cd.Loyalty_Status,
                    SUM(pd.cost * sft.quantity_sold) AS purchase
            FROM
                product_dimension pd
            INNER JOIN sales_fact_table sft ON sft.product_id = pd.product_id
            INNER JOIN customer_dimension cd ON cd.customer_id = sft.customer_id
            GROUP BY cd.Loyalty_Status) a) * 100 AS 'TotalPurchase (%)'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
        INNER JOIN
    customer_dimension cd ON cd.customer_id = sft.customer_id
GROUP BY cd.Loyalty_Status


---------------------------------------------------------------------------- SALES TRENDS------------------- ---------------------------------
--==============================================

--Daily Sales ($) Trend--

Use chocolate_sales;
SELECT 
    dayname(STR_TO_DATE(sft.Date, '%m/%d/%Y')) as Day_Name,
    SUM(pd.cost * sft.quantity_sold) AS 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
GROUP BY Day_Name,dayofweek(STR_TO_DATE(sft.Date, '%m/%d/%Y'))
ORDER BY dayofweek(STR_TO_DATE(sft.Date, '%m/%d/%Y'))

--===============================================

 --Monthly Sales($) Trend--
 
 Use chocolate_sales;
SELECT 
    monthname(STR_TO_DATE(sft.Date, '%m/%d/%Y')) as Month_Name,
    SUM(pd.cost * sft.quantity_sold) AS 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
GROUP BY Month_Name,month(STR_TO_DATE(sft.Date, '%m/%d/%Y'))
ORDER BY month(STR_TO_DATE(sft.Date, '%m/%d/%Y'))


--=======================================================
--Quarterly Sales ($) Trend

Use chocolate_sales;
SELECT 
    QUARTER(STR_TO_DATE(sft.Date, '%m/%d/%Y')) as Quarter,
    SUM(pd.cost * sft.quantity_sold) AS 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
GROUP BY Quarter
ORDER BY Quarter 

--===================================================

---Monthwise Purchase ($) Trend for Different Loyalty Status Customers---
Use chocolate_sales;
SELECT 
	cd.Loyalty_Status,
    monthname(STR_TO_DATE(sft.Date, '%m/%d/%Y')) as Month_Name,
    SUM(pd.cost * sft.quantity_sold) AS 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
    Inner join customer_dimension cd on cd.Customer_ID = sft.Customer_ID
GROUP BY cd.Loyalty_Status,Month_Name,month(STR_TO_DATE(sft.Date, '%m/%d/%Y'))
ORDER BY month(STR_TO_DATE(sft.Date, '%m/%d/%Y')) asc ,Sales desc

--====================================================
--Monthwise Sales ($) Trend for Different Brands

Use chocolate_sales;
SELECT 
	pd.Brand,
    monthname(STR_TO_DATE(sft.Date, '%m/%d/%Y')) as Month_Name,
    SUM(pd.cost * sft.quantity_sold) AS 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
   GROUP BY pd.Brand,Month_Name,month(STR_TO_DATE(sft.Date, '%m/%d/%Y'))
ORDER BY month(STR_TO_DATE(sft.Date, '%m/%d/%Y')) asc ,Sales desc



-------------------------------------------------------- PRODUCTS and BRANDS STATISTICS / ANALYTICS ---------------------------------


--Sales ($) Brandwise--
Use chocolate_sales;
SELECT 
   pd.Brand , SUM(pd.cost * sft.quantity_sold) AS 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
GROUP BY   pd.Brand
Order by Sales desc

----=================================
--Sales ($) by Chocolate Type--
Use chocolate_sales;
SELECT 
   pd.Chocolate_Type , SUM(pd.cost * sft.quantity_sold) AS 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
GROUP BY pd.Chocolate_Type
Order by Sales desc

--================================

--Top 5 Chocolates in terms of Sales ($)--

Use chocolate_sales;
Select b.Product_Name,b.Sales from (
Select 
a.Product_Name,Sales,DENSE_RANK() over (order by Sales desc) as rnk from
(SELECT 
   pd.Product_Name , SUM(pd.cost * sft.quantity_sold) AS 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
GROUP BY   pd.Product_Name) a )b
Where b.rnk < 6

--================================

--Sales ($) by Cost Segment--

Use chocolate_sales;
SELECT 
    CostSegment, SUM(a.cost * sft.quantity_sold) AS 'Sales'
FROM
    (SELECT 
        product_id,
            cost,
            CASE
                WHEN cost > 150 THEN 'Very Costly'
                WHEN cost > 100 THEN 'High Cost'
                WHEN cost > 50 THEN 'Average Cost'
                ELSE 'Inexpensive'
            END AS CostSegment
    FROM
        product_dimension pd) a
        INNER JOIN
    sales_fact_table sft ON sft.product_id = a.product_id
GROUP BY CostSegment

--==================================

--Change in Sales ($) by Month

Use chocolate_sales;
Select 
Month,Sales,LAG(Sales) over (order by Month),
(Sales - LAG(Sales) over (order by Month) ) /  LAG(Sales) over (order by Month) * 100 as 'Change_In_Sales'
 from(
SELECT 
    month(STR_TO_DATE(sft.Date, '%m/%d/%Y')) as Month,
    SUM(pd.cost * sft.quantity_sold) AS 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
GROUP BY Month
)a



-------------------------------------------------------- GEOGRAPHICAL SALES ANALYTICS ----------------------------------------------------------



--==================================================
 
--- Citywise - Sales ($) ---
Use chocolate_sales;
SELECT 
   ld.City , SUM(pd.cost * sft.quantity_sold) AS 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
		INNER JOIN 
	location_dimension ld on ld.Location_ID=sft.location_id
GROUP BY   ld.City
Order by Sales desc

--=====================================
--Sales ($) by Cocoa Origin Region--
Use chocolate_sales;
SELECT 
    pd.Origin_Region,
    SUM(pd.cost * sft.quantity_sold) AS 'Sales'
FROM
    product_dimension pd
        INNER JOIN
    sales_fact_table sft ON sft.product_id = pd.product_id
GROUP BY pd.Origin_Region
ORDER BY Sales DESC






 
 






