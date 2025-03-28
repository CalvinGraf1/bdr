SET search_path = pagila;

-- BEGIN Exercice 01
SELECT
    customer_id,
    last_name AS nom,
    email
FROM customer
WHERE first_name='PHYLLIS'
    AND store_id=1
ORDER BY customer_id DESC;
-- END Exercice 01


-- BEGIN Exercice 02
SELECT
    title AS titre,
    release_year AS annee_sortie
FROM film
WHERE rating = 'R'
    AND length < 60
    AND replacement_cost = '12.99'
ORDER BY title;
-- END Exercice 02


-- BEGIN Exercice 03
SELECT
    country,
    city,
    postal_code
FROM city c
INNER JOIN country ctry
    ON c.country_id = ctry.country_id
INNER JOIN address a
    ON c.city_id = a.city_id
WHERE c.country_id >= 63
    AND c.country_id <= 67
    OR country='France'
ORDER BY country, city, postal_code;
-- END Exercice 03


-- BEGIN Exercice 04
SELECT
    customer_id,
    first_name AS prenom,
    last_name AS nom
FROM customer c
INNER JOIN address a
    ON c.address_id = a.address_id
INNER JOIN city
    ON a.city_id = city.city_id
WHERE a.city_id = 171
    AND store_id = 1
ORDER BY first_name;
-- END Exercice 04


-- BEGIN Exercice 05
SELECT DISTINCT
    c1.first_name AS prenom_1,
    c1.last_name AS nom_1,
    c2.first_name AS prenom_2,
    c2.last_name AS nom_2
FROM rental r1
INNER JOIN rental r2
    ON r1.inventory_id = r2.inventory_id
INNER JOIN customer c1
    ON r1.customer_id = c1.customer_id
INNER JOIN customer c2
    ON c2.customer_id = r2.customer_id
WHERE c1.customer_id != c2.customer_id
GROUP BY c1.first_name, c1.last_name, c2.first_name, c2.last_name;
-- END Exercice 05


-- BEGIN Exercice 06
SELECT
    first_name AS prenom,
    last_name AS nom
FROM actor
WHERE actor_id IN (
    SELECT
        actor_id
    FROM film_actor
    WHERE film_id IN (
        SELECT
            film_id
        FROM film_category
        WHERE category_id IN (
            SELECT
                category_id
            FROM category
            WHERE name = 'Horror'
        )
    )
)
AND (first_name LIKE 'K%' OR last_name LIKE 'D%');
-- END Exercice 06


-- BEGIN Exercice 07a
SELECT
    f.film_id AS id,
    f.title AS titre,
    (f.rental_rate / f.rental_duration) AS prix_de_location_par_jour
FROM film f
WHERE
    (f.rental_rate / f.rental_duration) <= 1.00
    AND NOT EXISTS (
        SELECT 1
        FROM inventory i
        INNER JOIN rental r
            ON i.inventory_id = r.inventory_id
        WHERE i.film_id = f.film_id
    );
-- END Exercice 07a

-- BEGIN Exercice 07b
SELECT
    f.film_id AS id,
    f.title AS titre,
    (f.rental_rate / f.rental_duration) AS prix_de_location_par_jour
FROM
    film f
LEFT JOIN inventory i
    ON f.film_id = i.film_id
LEFT JOIN rental r
    ON i.inventory_id = r.inventory_id
WHERE
    (f.rental_rate / f.rental_duration) <= 1.00
GROUP BY f.film_id, f.title, f.rental_rate, f.rental_duration
HAVING COUNT(r.rental_id) = 0;
-- END Exercice 07b


-- BEGIN Exercice 08a
SELECT c.customer_id AS id,
       c.last_name AS nom,
       c.first_name AS prenom
FROM customer c
INNER JOIN address a
    ON c.address_id = a.address_id
INNER JOIN city
    ON a.city_id = city.city_id
INNER JOIN country ctry
    ON city.country_id = ctry.country_id
WHERE ctry.country = 'Spain'
AND EXISTS (
    SELECT 1
    FROM rental r
    INNER JOIN inventory i
        ON r.inventory_id = i.inventory_id
    WHERE r.customer_id = c.customer_id
        AND r.return_date IS NULL
)
ORDER BY c.last_name;
-- END Exercice 08a

-- BEGIN Exercice 08b
SELECT c.customer_id AS id,
       c.last_name AS nom,
       c.first_name AS prenom
FROM customer c
INNER JOIN address a
    ON c.address_id = a.address_id
INNER JOIN city
    ON a.city_id = city.city_id
INNER JOIN country ctry
    ON city.country_id = ctry.country_id
WHERE ctry.country = 'Spain'
    AND c.customer_id IN (
    SELECT r.customer_id
    FROM rental r
    WHERE r.return_date IS NULL
)
ORDER BY c.last_name;
-- END Exercice 08b

-- BEGIN Exercice 08c
SELECT c.customer_id AS id,
       c.last_name AS nom,
       c.first_name AS prenom
FROM customer c
INNER JOIN address a
    ON c.address_id = a.address_id
INNER JOIN city
    ON a.city_id = city.city_id
INNER JOIN country ctry
    ON city.country_id = ctry.country_id
INNER JOIN rental r
    ON c.customer_id = r.customer_id
INNER JOIN inventory i
    ON r.inventory_id = i.inventory_id
WHERE ctry.country = 'Spain'
    AND r.return_date IS NULL
ORDER BY c.last_name;
-- END Exercice 08c


-- BEGIN Exercice 09 (Bonus)
SELECT customer_id,
       first_name AS prenom,
       last_name AS nom
FROM customer
WHERE NOT EXISTS (
    SELECT film_id
    FROM film_actor
    INNER JOIN actor
        ON film_actor.actor_id = actor.actor_id
    WHERE actor.first_name = 'EMILY'
      AND actor.last_name = 'DEE'
    EXCEPT
    SELECT inventory.film_id
    FROM rental
    INNER JOIN inventory
        ON rental.inventory_id = inventory.inventory_id
    WHERE rental.customer_id = customer.customer_id
);
-- END Exercice 09 (Bonus)


-- BEGIN Exercice 10
SELECT
    f.title AS titre,
    COUNT(fa.actor_id) AS nb_acteurs
FROM film f
INNER JOIN film_category fc
    ON f.film_id = fc.film_id
INNER JOIN category c
    ON fc.category_id = c.category_id
LEFT JOIN film_actor fa
    ON f.film_id = fa.film_id
WHERE
    c.name = 'Drama'
GROUP BY f.title
HAVING COUNT(fa.actor_id) < 5
ORDER BY COUNT(fa.actor_id) DESC;
-- END Exercice 10


-- BEGIN Exercice 11
SELECT
    c.category_id AS id,
    c.name AS nom,
    COUNT(fc.film_id) AS nb_films
FROM category c
INNER JOIN film_category fc
    ON c.category_id = fc.category_id
GROUP BY c.category_id, c.name
HAVING COUNT(fc.film_id) > 65
ORDER BY COUNT(fc.film_id) DESC;
-- END Exercice 11


-- BEGIN Exercice 12
SELECT
    f.film_id AS id,
    f.title AS titre,
    f.length AS duree
FROM film f
WHERE
    f.length = (
        SELECT MIN(length)
        FROM film
    )
ORDER BY f.film_id;
-- END Exercice 12


-- BEGIN Exercice 13a
SELECT
    f.film_id AS id,
    f.title AS titre
FROM film f
WHERE
    f.film_id IN (
        SELECT
            fa.film_id
        FROM film_actor fa
        WHERE fa.actor_id IN (
            SELECT
                actor_id
            FROM film_actor
            GROUP BY actor_id
            HAVING COUNT(*) > 40
        )
    )
ORDER BY f.title;
-- END Exercice 13a

-- BEGIN Exercice 13b
SELECT DISTINCT
    f.film_id AS id,
    f.title AS titre
FROM film f
INNER JOIN film_actor fa
    ON f.film_id = fa.film_id
INNER JOIN (
    SELECT
        actor_id
    FROM film_actor
    GROUP BY actor_id
    HAVING COUNT(film_id) > 40
) AS a_ID
    ON fa.actor_id = a_ID.actor_id
ORDER BY f.title;
-- END Exercice 13b


-- BEGIN Exercice 14
SELECT
    SUM(length) / (8 * 60) AS nb_jours
FROM
    film;
-- END Exercice 14


-- BEGIN Exercice 15
SELECT
    c.customer_id AS id,
    c.last_name AS nom,
    c.email AS email,
    ctry.country AS pays,
    COUNT(p.payment_id) AS nb_locations,
    SUM(p.amount) AS depense_totale,
    AVG(p.amount) AS depense_moyenne
FROM customer c
INNER JOIN address a
    ON c.address_id = a.address_id
INNER JOIN city
    ON a.city_id = city.city_id
INNER JOIN country ctry
    ON city.country_id = ctry.country_id
INNER JOIN payment p
    ON c.customer_id = p.customer_id
WHERE
    ctry.country IN ('Switzerland', 'France', 'Germany')
GROUP BY c.customer_id, ctry.country, c.last_name
HAVING AVG(p.amount) > 3.0
ORDER BY ctry.country, c.last_name;
-- END Exercice 15


-- BEGIN Exercice 16a
SELECT
    COUNT(*)
FROM payment
WHERE
    amount <= 9;
-- END Exercice 16a

-- BEGIN Exercice 16b
DELETE
FROM payment
WHERE
    amount <= 9;
-- END Exercice 16b

-- BEGIN Exercice 16c
SELECT
    COUNT(*)
FROM payment
WHERE
    amount <= 9;
-- END Exercice 16c


-- BEGIN Exercice 17
UPDATE payment
SET
    amount = amount * 1.5,
    payment_date = CURRENT_TIMESTAMP
WHERE
    amount > 4;
-- END Exercice 17


-- BEGIN Exercice 18
BEGIN;

INSERT INTO city(country_id, city)
    SELECT
        country_id,
        'Nyon'
    FROM country ctry
    WHERE ctry.country = 'Switzerland';


INSERT INTO address(address, postal_code, phone, district, city_id)
    SELECT 'Rue du centre',
           '1260',
           '0213600000',
           'Vaud',
           city_id
    FROM city c
    WHERE c.city = 'Nyon';

INSERT INTO customer(first_name, last_name, email, store_id, address_id)
    SELECT 'Guillaume',
           'Ransome',
           'gr@bluewin.ch',
           1,
           address_id
    FROM address
    WHERE address LIKE 'Rue du centre';

COMMIT;
-- END Exercice 18

-- 18b : Génération Automatique de l'ID
-- Les IDs (customer_id, address_id, etc.) sont généralement générés automatiquement par la base de données pour éviter les conflits et garantir l'unicité.

-- 18c : Valeurs des Clés Étrangères
-- Les valeurs pour les clés étrangères ([CITY_ID], [ADDRESS_ID]) doivent être récupérées à partir des tables existantes (par exemple, la table city pour le CITY_ID).


-- BEGIN Exercice 18d
SELECT first_name AS prenom,
    last_name AS nom,
    email AS email,
    store_id AS store_id,
    city AS ville,
    address AS address
FROM customer
INNER JOIN address a
    ON a.address_id = customer.address_id
INNER JOIN city c
    ON c.city_id = a.city_id
WHERE first_name LIKE 'Guillaume'
    AND last_name LIKE 'Ransome';
-- END Exercice 18d
