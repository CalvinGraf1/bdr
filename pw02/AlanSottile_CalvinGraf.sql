SET search_path = pagila;

-- BEGIN Exercice 01
SELECT customer_id, last_name, email
FROM customer
	INNER JOIN store s
	on s.store_id = 1
WHERE first_name = 'PHYLLIS'
ORDER BY customer_id DESC;
-- END Exercice 01


-- BEGIN Exercice 02
SELECT title, release_year
FROM film
WHERE rating = 'R'
AND length < 60
AND replacement_cost = '12.99'
ORDER BY title;
-- END Exercice 02


-- BEGIN Exercice 03
SELECT ctry.country, c.city, a.postal_code
FROM customer cust
    INNER JOIN address a
        on a.address_id = cust.address_id
    INNER JOIN city c
        on c.city_id = a.city_id
    INNER JOIN country ctry
        on c.country_id = ctry.country_id
WHERE ctry.country = 'France'
    OR ctry.country_id >= 63 AND ctry.country_id <= 67
ORDER BY ctry.country, c.city, a.postal_code;
-- END Exercice 03


-- BEGIN Exercice 04
SELECT customer_id, first_name, last_name
FROM customer c
	INNER JOIN address a
		on a.city_id = 171
WHERE active = true
AND store_id = 1
ORDER BY first_name;
-- END Exercice 04


-- BEGIN Exercice 05
-- END Exercice 05


-- BEGIN Exercice 06
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
    SELECT actor_id
    FROM film_actor
    WHERE film_id IN (
        SELECT film_id
        FROM film_category
        WHERE category_id IN (
            SELECT category_id
            FROM category
            WHERE name = 'Horror'
        )
    )
)
AND (first_name LIKE 'K%' OR last_name LIKE 'D%');
-- END Exercice 06


-- BEGIN Exercice 07a
-- END Exercice 07a

-- BEGIN Exercice 07b
-- END Exercice 07b


-- BEGIN Exercice 08a
-- END Exercice 08a

-- BEGIN Exercice 08b
-- END Exercice 08b

-- BEGIN Exercice 08c
-- END Exercice 08c


-- BEGIN Exercice 09 (Bonus)
-- END Exercice 09 (Bonus)


-- BEGIN Exercice 10
-- END Exercice 10


-- BEGIN Exercice 11
-- END Exercice 11


-- BEGIN Exercice 12
-- END Exercice 12


-- BEGIN Exercice 13a
-- END Exercice 13a

-- BEGIN Exercice 13b
-- END Exercice 13b


-- BEGIN Exercice 14
-- END Exercice 14


-- BEGIN Exercice 15
-- END Exercice 15


-- BEGIN Exercice 16a
-- END Exercice 16a

-- BEGIN Exercice 16b
-- END Exercice 16b

-- BEGIN Exercice 16c
-- END Exercice 16c


-- BEGIN Exercice 17
-- END Exercice 17


-- BEGIN Exercice 18
-- END Exercice 18

-- BEGIN Exercice 18d
-- END Exercice 18d
