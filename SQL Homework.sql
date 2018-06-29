use sakila;

#1a. Display the first and last names of all actors from the table actor.

select first_name, last_name
from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

select first_name, last_name from actor;
select concat(first_name," ", last_name) as "Actor Name" from actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
# What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";

#2b. Find all actors whose last name contain the letters GEN:

SELECT * FROM actor
WHERE last_name LIKE '%GEN%';

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT * FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.

ALTER TABLE actor
    ADD COLUMN middle_name varchar(255) NOT NULL
    AFTER first_name;
SELECT * FROM actor;

#3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.

ALTER TABLE actor
MODIFY middle_name Blob;
SELECT * FROM actor;

#3c. Now delete the middle_name column.

ALTER TABLE actor
DROP middle_name;

#4a. List the last names of actors, as well as how many actors have that last name.

SELECT COUNT(last_name) as COUNT, last_name 
  FROM actor
 GROUP BY last_name;
 
 #4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
 
 SELECT COUNT(last_name) as COUNT, last_name 
  FROM actor
 GROUP BY last_name
HAVING COUNT(last_name) = 2;

#4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor
   SET first_name = 'HARPO'
 WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
 SELECT * FROM actor WHERE first_name = 'HARPO';
 
 #4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
 #78 and 106

UPDATE actor
SET first_name = 
CASE WHEN first_name = 'HARPO' THEN 'GROUCHO'
ELSE 'MUCHO GROUCHO'
	END
	WHERE actor_id = 78 OR actor_id = 106;
SELECT * FROM actor WHERE first_name LIKE '%GROUCHO%';

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
staff.address_id = address.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, SUM(amount) as Amount
FROM payment
INNER JOIN staff ON
staff.staff_id = payment.staff_id
where payment_date LIKE '2005-08%'
group by last_name;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT film.title, COUNT(actor_id) as Count
FROM film 
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film.title, COUNT(inventory_id) as Copies
FROM film
INNER JOIN inventory 
ON film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible";

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT customer.last_name, customer.first_name, SUM(amount) as Amount
FROM payment
INNER JOIN customer
ON payment.customer_id = customer.customer_id
GROUP BY customer.customer_id
ORDER BY last_name ASC;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. 

SELECT title FROM film
WHERE language_id in
	(SELECT language_id 
	FROM language
	WHERE name = "English" )
AND (title LIKE "K%") OR (title LIKE "Q%");

SELECT title
FROM film
WHERE language_id IN
(SELECT language_id FROM language WHERE name = 'English') AND ((title LIKE 'K%') OR (title LIKE 'Q%'));

#7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT last_name, first_name
FROM actor
WHERE actor_id in
	(SELECT actor_id FROM film_actor
	WHERE film_id in 
		(SELECT film_id FROM film
		WHERE title = "Alone Trip"));
        
#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT country.country, customer.last_name, customer.first_name, customer.email
FROM country
LEFT JOIN customer
ON country.country_id = customer.customer_id
WHERE country = 'Canada';

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

SELECT film.title, category.name
FROM film
INNER JOIN film_category 
	ON (film.film_id = film_category.film_id)
INNER JOIN category
	ON (category.category_id = film_category.category_id)
WHERE name = 'family';
		
#7e. Display the most frequently rented movies in descending order.

SELECT title, COUNT(title) as 'Rentals'
FROM film
INNER JOIN inventory
	ON(film.film_id = inventory.film_id)
INNER JOIN rental
	ON (inventory.inventory_id = rental.inventory_id)
GROUP by title
ORDER BY rentals desc;

#7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, SUM(amount) AS Gross
FROM payment
INNER JOIN rental
	ON (payment.rental_id = rental.rental_id)
INNER JOIN inventory
	ON (inventory.inventory_id = rental.inventory_id)
INNER JOIN store
	ON (store.store_id = inventory.store_id)
GROUP BY store.store_id;

#7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country
FROM country
INNER JOIN city 
	ON (country.country_id = city.country_id)
INNER JOIN address
	ON (address.city_id = city.city_id)
INNER JOIN store
	ON (store.address_id = address.address_id);
    
#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

#This was a hard one

SELECT category.name AS Genre,
	concat('$',format(SUM(payment.amount),2)) AS Gross_Revenue FROM category
JOIN film_category 
	ON category.category_id=film_category.category_id
JOIN inventory 
	ON film_category.film_id=inventory.film_id
JOIN rental 
	ON inventory.inventory_id=rental.inventory_id
JOIN payment 
	ON rental.rental_id=payment.rental_id
GROUP BY Genre
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view

create view Top5GrossGenres AS
SELECT category.name AS Genre,
	concat('$',format(SUM(payment.amount),2)) AS Gross_Revenue FROM category
JOIN film_category 
	ON category.category_id=film_category.category_id
JOIN inventory 
	ON film_category.film_id=inventory.film_id
JOIN rental 
	ON inventory.inventory_id=rental.inventory_id
JOIN payment 
	ON rental.rental_id=payment.rental_id
GROUP BY Genre
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

#8b. How would you display the view that you created in 8a?

select * from Top5GrossGenres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view Top5GrossGenres;
