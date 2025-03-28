SET search_path = pagila;

--
-- Triggerss
---------------------------

-- BEGIN Exercice 01
CREATE OR REPLACE FUNCTION payment_increase() 
RETURNS TRIGGER AS 
$$ 
BEGIN 
	NEW.amount = NEW.amount * 1.08;
	NEW.payment_date = NOW();
	RETURN NEW;
END 
$$ 
LANGUAGE plpgsql;

CREATE TRIGGER payment_increase_trigger BEFORE
INSERT 
	ON payment 
	FOR EACH ROW 
	EXECUTE FUNCTION payment_increase();

-- VERIFICATION
INSERT INTO payment (
        customer_id,
        staff_id,
        rental_id,
        payment_date,
        amount
    )
VALUES (1, 1, 1, '2023-06-12 13:16:00', 100);

SELECT *
FROM payment
WHERE customer_id = 1
    AND staff_id = 1
    AND rental_id = 1;
-- END Exercice 01

-- BEGIN Exercice 02
DROP TABLE IF EXISTS staff_creation_log;
CREATE TABLE staff_creation_log(
    when_created DATE,
    username VARCHAR(30)
);
CREATE OR REPLACE FUNCTION create_staff_log() RETURNS TRIGGER AS 
$$ 
BEGIN
	INSERT INTO staff_creation_log
	VALUES (NOW(), NEW.username);
	RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;

CREATE TRIGGER on_staff_creation BEFORE
INSERT 
	ON staff 
FOR EACH ROW 
EXECUTE FUNCTION create_staff_log();

-- VERIFICATION 
INSERT INTO staff (
        first_name,
        last_name,
        address_id,
        email,
        store_id,
        username,
        password,
        picture
    )
VALUES (
        'Calvin',
        'Alan',
        1,
        'CalvinAlan@gmail.com',
        1,
        'CalvinA',
        'hackerman',
        ''
    );
	
SELECT *
FROM staff_creation_log
WHERE username = 'CalvinA';
-- END Exercice 02

-- BEGIN Exercice 03
CREATE OR REPLACE FUNCTION update_staff_email() RETURNS TRIGGER AS 
$$ 
BEGIN NEW.email = CONCAT(
        NEW.first_name,
        '.',
        NEW.last_name,
        '@sakilastaff.com'
    );
RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;

CREATE TRIGGER staff_email_trigger BEFORE
INSERT 
	ON staff 
FOR EACH ROW 
EXECUTE FUNCTION update_staff_email();

CREATE TRIGGER on_staff_update_email BEFORE
UPDATE 
	ON staff 
FOR EACH ROW 
EXECUTE FUNCTION update_staff_email();

--VERIFICATION
INSERT INTO staff (
        first_name,
        last_name,
        address_id,
        email,
        store_id,
        username,
        password,
        picture
    )
VALUES (
        'Calvin',
        'Alan',
        1,
        'CalvinAlan@gmail.com',
        1,
        'CalvinA',
        'hackerman',
        ''
    );
	
-- Test creation
SELECT *
FROM staff
WHERE username = 'CalvinA';
UPDATE staff
SET email = email;

-- Test update
SELECT *
FROM staff;

-- END Exercice 03

--
-- Vues
---------------------------

-- BEGIN Exercice 04
CREATE VIEW staff_address
    AS
    SELECT 
		f.first_name AS prénom, 
		f.last_name AS nom,
		a.phone AS numéro_tel, 
		a.address AS adresse,
		a.postal_code as NPA, 
		c.city as Ville
           FROM staff f
               JOIN address a 
				ON f.address_id = a.address_id
               JOIN city c 
				ON a.city_id = c.city_id;
				
-- VERIFICATION
SELECT * 
FROM staff_address;

-- Réponse : Non, l'update ne se fait pas car la vue affecte plus d'une table
-- END Exercice 04

-- BEGIN Exercice 05
CREATE VIEW return_reminders
AS SELECT * FROM (
    SELECT
        email,
        film.title,
        ROUND(EXTRACT(EPOCH FROM now() - (rental_date + rental_duration * INTERVAL '1 day'))/86400) AS jour_retard
    FROM customer
        JOIN rental
            ON customer.customer_id = rental.customer_id
        JOIN inventory
            ON rental.inventory_id = inventory.inventory_id
        JOIN film
            ON inventory.film_id = film.film_id
    WHERE return_date IS NULL
                ) AS total
WHERE jour_retard > 0;
-- VERIFICATION
SELECT * 
FROM (
    SELECT 
		email,
        film.title,
        ROUND(EXTRACT(EPOCH FROM now() - (rental_date + rental_duration * INTERVAL '1 day'))/86400) AS jour_retard
    FROM customer
        JOIN rental
            ON customer.customer_id = rental.customer_id
        JOIN inventory
            ON rental.inventory_id = inventory.inventory_id
        JOIN film
            ON inventory.film_id = film.film_id
    WHERE return_date IS NULL
              ) return_date_null
WHERE jour_retard > 0;
-- END Exercice 05

-- BEGIN Exercice 06
CREATE VIEW return_reminders_more_than_3_days AS
    SELECT
        email,
        title,
        jour_retard
    FROM return_reminders
    WHERE jour_retard > 3;
-- VERIFICATION
SELECT * FROM (
    SELECT email,
           film.title,
           ROUND(EXTRACT(EPOCH FROM now() - (rental_date + rental_duration * INTERVAL '1 day'))/86400) AS jour_retard
    FROM customer
        JOIN rental
            ON customer.customer_id = rental.customer_id
        JOIN inventory
            ON rental.inventory_id = inventory.inventory_id
        JOIN film
            ON inventory.film_id = film.film_id
    WHERE return_date IS NULL
              ) return_date_null
WHERE jour_retard > 3;
-- END Exercice 06

-- BEGIN Exercice 07
CREATE VIEW client_nb_rental
    AS
    SELECT 
		c.customer_id, 
		first_name, 
		last_name, 
		COUNT(rental_id) AS nb_rental
        FROM customer c
            JOIN rental r
                ON c.customer_id = r.customer_id
    GROUP BY c.customer_id, first_name, last_name;
-- Affiche les 20 clients avec le plus de locations
SELECT * 
FROM client_nb_rental 
ORDER BY nb_rental DESC
LIMIT 20;
-- END Exercice 07

-- BEGIN Exercice 08
CREATE VIEW locations_par_jour AS
SELECT 
	date_trunc('day', rental.rental_date) AS rental_day,
    COUNT(*)
FROM rental
GROUP BY rental_day;

-- Réponse : Locations effectuées le 1er août 2005 : 671

--VERIFICATION
SELECT 
	count AS location_2005_08_01
FROM locations_par_jour
WHERE rental_day = '2005-08-01';
-- END Exercice 08

--
-- Procédures / Fonctions
---------------------------

-- BEGIN Exercice 09
CREATE OR REPLACE FUNCTION nb_film_store(id INT) 
RETURNS INTEGER AS 
$$ 
BEGIN RETURN (
        SELECT 
			COUNT(*)
        FROM inventory
        WHERE inventory.store_id = id
    );
END;
$$ LANGUAGE plpgsql;
-- REPONSE
SELECT 
	pagila.nb_film_store(1);
-- Magasin 1 : 2270

SELECT 
	pagila.nb_film_store(2);
-- Magasin 2 : 2311
-- VERIFICATION
SELECT 
	COUNT(*)
FROM inventory
WHERE inventory.store_id = 1;
SELECT 
	COUNT(*)
FROM inventory
WHERE inventory.store_id = 2;
-- END Exercice 09

-- BEGIN Exercice 10
CREATE OR REPLACE PROCEDURE update_filmDate_to_now()
LANGUAGE plpgsql AS 
$$ 
BEGIN
UPDATE film
SET last_update = NOW();
END;
$$;
-- Réponse : Avant : 2017-09-10 17:46:03.905795 +00:00
--           Après : 2023-12-06 15:41:27.059987 +00:00
-- VERIFICATION
SELECT 
	film_id,
    last_update
FROM film;
CALL update_filmDate_to_now();
SELECT 
	film_id,
    last_update
FROM film;
-- END Exercice 10

--
-- SQL Avancé
---------------------------

-- BEGIN Exercice 11
WITH RECURSIVE closeToEd(actor_id, n)
    AS (
    SELECT 
		actor_id,
		0
    FROM film_actor
    WHERE actor_id
              IN (SELECT 
					actor_id
                  FROM actor
                  WHERE first_name = 'ED'
                    AND last_name = 'GUINESS')
    UNION
    SELECT 
		fa2.actor_id, 
		n+1
    FROM closeToEd
        JOIN film_actor fa
            ON fa.actor_id = closeToEd.actor_id
        JOIN film_actor fa2
            ON fa2.film_id = fa.film_id
        JOIN film f
            ON fa.film_id = f.film_id
    WHERE n < 2
      AND f.length < 50
    )
SELECT 
	actor_id
FROM closeToEd
GROUP BY actor_id;

-- VERIFICATION MANUELLE
-- Courts-métrages de ED - Résultat : 931
SELECT 
	actor_id, 
	fa.film_id
FROM film_actor fa
    JOIN film f 
        ON fa.film_id = f.film_id
WHERE actor_id = 179 
  AND length <= 50;

-- ID des acteurs du court-métrage d'ED 931 - Résultat 36 et 179
SELECT 
	actor_id 
FROM film_actor 
WHERE film_id = 931;

-- ID du courts-métrages avec l'ID de l'acteur 36 - Résultat : 15, 410 et 931
SELECT
	actor_id, 
	fa.film_id
FROM film_actor fa
    JOIN film f 
        ON fa.film_id = f.film_id
WHERE actor_id = 36 
  AND length <= 50;
  
-- ID des acteurs du court-métrage d'ID 15, (Distance de 2)
SELECT actor_id 
FROM film_actor 
WHERE film_id = 15;

-- ID des acteurs du court-métrage d'ID 410, (Distance de 2)
SELECT actor_id 
FROM film_actor 
WHERE film_id = 410;
-- END Exercice 11

-- BEGIN Exercice 12
SELECT 
	payment_id, 
	customer_id, 
	payment_date, 
	amount, 
	sum(amount) OVER (PARTITION BY customer_id 
	ORDER BY payment_date) cumulative_amount
FROM payment
ORDER BY customer_id, payment_date;
-- VERIFICATION
SELECT 
	customer_id, 
	payment_date, 
	amount
FROM payment
WHERE customer_id = 1
ORDER BY payment_date;
-- END Exercice 12
