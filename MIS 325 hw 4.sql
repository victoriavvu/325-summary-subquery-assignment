--MIS 325 HW 4
--Victoria Vu
--vtv244

--Question 1
SELECT  COUNT(customer_id) AS count_of_customers,
        MIN(stay_credits_earned) AS min_credits,
        MAX(stay_credits_earned) AS max_credits
FROM customer;

--Question 2
SELECT c.customer_id, COUNT(r.reservation_id) AS number_of_reservations, MIN(check_in_date) AS earliest_check_in
FROM customer c INNER JOIN reservation r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

--Question 3
SELECT city, state, AVG(ROUND(stay_credits_earned)) AS avg_stay_credits_earned
FROM customer
GROUP BY city, state
ORDER BY state ASC, avg_stay_credits_earned DESC;

--Question 4
SELECT c.customer_id, c.last_name, o.room_number, COUNT(r.reservation_id) AS stay_count
FROM    customer c 
        INNER JOIN reservation r ON c.customer_id = r.customer_id
        INNER JOIN reservation_details d ON r.reservation_id = d.reservation_id
        INNER JOIN room o ON r.location_id = o.location_id
WHERE o.location_id = 1 
GROUP BY c.customer_id, c.last_name, o.room_number
ORDER BY c.customer_id ASC, stay_count DESC;

--Question 5
SELECT c.customer_id, c.last_name, o.room_number, COUNT(r.reservation_id) AS stay_count
FROM    customer c 
        INNER JOIN reservation r ON c.customer_id = r.customer_id
        INNER JOIN reservation_details d ON r.reservation_id = d.reservation_id
        INNER JOIN room o ON r.location_id = o.location_id
WHERE o.location_id = 1 AND status = 'C'
GROUP BY c.customer_id, c.last_name, o.room_number
HAVING COUNT(r.reservation_id) > 2
ORDER BY c.customer_id ASC, stay_count DESC;

--Question 6A
SELECT location_name, check_in_date, SUM(number_of_guests) AS total_guests
FROM location l INNER JOIN reservation r ON l.location_id = r.location_id
WHERE check_in_date > SYSDATE
GROUP BY ROLLUP (location_name,check_in_date)

--Question 6B
--The ROLLUP operator adds a final subtotal for queries with 
--aggregrate functions at any level needed, as well as a grand total.   
--The CUBE operator generates a subtotal for every possible combination 
--(instead of a grand subtotal). CUBE can be helpful when we want to 
--differentiate each group, instead of combining all subtotals.

--Question 7
SELECT  feature_name, COUNT(location_id) AS count_of_locations
FROM    features f
        INNER JOIN location_features_linking lf ON f.feature_id = lf.feature_id
GROUP BY feature_name
HAVING COUNT(location_id) > 2

--Question 8
SELECT customer_id, first_name, last_name, email
FROM customer
WHERE customer_id NOT IN (SELECT customer_id 
                            FROM reservation);

--Question 9
SELECT first_name, last_name, email, phone, stay_credits_earned
FROM customer
WHERE stay_credits_earned > (SELECT AVG(ALL stay_credits_earned) FROM customer)
ORDER BY stay_credits_earned DESC;

--Question 10
SELECT c.city, c.state, total_earned - total_used AS credits_remaining
FROM customer c  JOIN (SELECT city, state, 
                            SUM(stay_credits_earned) AS total_earned, 
                            SUM(stay_credits_used) AS total_used
                            FROM customer
                            GROUP BY city, state
                            ORDER BY city, state)c2
                            ON c.city = c2.city
ORDER BY credits_remaining DESC

--Question 11
SELECT r.confirmation_nbr, r.date_created, r.check_in_date, r.status, d.room_id 
FROM reservation r INNER JOIN reservation_details d ON r.reservation_id = d.reservation_id
WHERE d.room_id IN  (SELECT room_id
                    FROM reservation_details
                    GROUP BY room_id
                    HAVING COUNT(room_id) < 5)
                AND status NOT IN ('C')    
ORDER BY room_id;

--Question 12
SELECT cardholder_first_name, cardholder_last_name, card_number, expiration_date, cc_id
FROM    customer_payment p JOIN 
        (SELECT customer_id, COUNT(reservation_id)
        FROM reservation 
        WHERE status = 'C'
        GROUP BY customer_id
        HAVING COUNT(reservation_id) = 1) r
ON p.customer_id = r.customer_id
WHERE card_type = 'MSTR'




