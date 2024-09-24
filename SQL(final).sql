USE olist_store;

select count(*) from olist_customers_dataset;
select count(*) from olist_order_items_dataset;
select count(*) from olist_order_payments_dataset;
select count(*) from olist_order_reviews_dataset;
select count(*) from olist_orders_dataset;
select count(*) from olist_products_dataset;
select count(*) from olist_sellers_dataset;
select count(*) from product_category_name_translation;

-----------------------------------------------------------------------------------------------------------------------------------------------------------
#KPI 1

SELECT DAYOFWEEK('2024-09-10') AS DayOfWeek;

SELECT 
  CASE 
    WHEN WEEKDAY(o.order_purchase_timestamp) IN (6, 7) THEN 'Weekend' 
    ELSE 'Weekday' 
  END AS Day_End,
  ROUND(
    SUM(p.payment_value) / (SELECT SUM(payment_value) FROM olist_order_payments_dataset) * 100,2) AS percentage_pmtvalue
FROM 
  olist_order_payments_dataset p
JOIN 
  olist_orders_dataset o ON p.order_id = o.order_id
GROUP BY 
  Day_End;
  
-------------------------------------------------------------------------------------------------------------------------------------------------------------------  

# KPI 2

SELECT pmt.payment_type, rw5.review_score, COUNT(pmt.order_id) AS Total_Orders 
FROM olist_order_payments_dataset AS pmt
JOIN
(SELECT DISTINCT ord.order_id, rw.review_score
FROM olist_orders_dataset AS ord
JOIN olist_order_reviews_dataset AS rw ON ord.order_id = rw.order_id
WHERE review_score = 5) AS rw5
ON pmt.order_id = rw5.order_id
where payment_type = 'credit_card'
GROUP BY pmt.payment_type,rw5.review_score;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
# KPI 3

SELECT prod.product_category_name,
                           ROUND(AVG(DATEDIFF(ord.order_delivered_customer_date, ord.order_purchase_timestamp)), 0) AS avg_delivery_date
FROM olist_orders_dataset AS ord
JOIN (
    SELECT oi.order_id, p.product_category_name
    FROM olist_order_items_dataset AS oi
    JOIN olist_products_dataset AS p
    ON oi.product_id = p.product_id
) AS prod
ON ord.order_id = prod.order_id
WHERE prod.product_category_name = 'pet_shop'
GROUP BY prod.product_category_name;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#KPI 4

#Avg. Payment Price

SELECT cust.customer_city, 
       ROUND(AVG(item.price), 0) AS avg_price
FROM olist_customers_dataset AS cust
JOIN olist_orders_dataset AS ord ON cust.customer_id = ord.customer_id
JOIN olist_order_payments_dataset AS pmt ON ord.order_id = pmt.order_id
JOIN olist_order_items_dataset AS item ON ord.order_id = item.order_id
WHERE cust.customer_city = "sao paulo"
GROUP BY cust.customer_city;


#Avg. Payment Value 

SELECT cust.customer_city, ROUND(AVG(pmt.payment_value), 0) AS avg_payment_value
FROM olist_customers_dataset AS cust
INNER JOIN olist_orders_dataset AS ord ON cust.customer_id = ord.customer_id
INNER JOIN olist_order_payments_dataset AS pmt ON ord.order_id = pmt.order_id
WHERE customer_city = "sao paulo";

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

# KPI 5
SELECT rw.review_score, ROUND(AVG(DATEDIFF(ord.order_delivered_customer_date, ord.order_purchase_timestamp)), 0) AS avg_Shipping_Days
FROM olist_orders_dataset AS ord
JOIN olist_order_reviews_dataset AS rw ON rw.order_id = ord.order_id
GROUP BY rw.review_score
ORDER BY rw.review_score;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
#KPI 6

SELECT trans.product_category_name_english,
       Round(SUM(pmt.payment_value),2) AS total_revenue
FROM olist_order_items_dataset AS oi
JOIN olist_products_dataset AS prod
ON oi.product_id = prod.product_id
JOIN olist_order_payments_dataset AS pmt
ON oi.order_id = pmt.order_id
JOIN product_category_name_translation AS trans
ON prod.product_category_name = trans.ï»¿product_category_name
GROUP BY trans.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;

