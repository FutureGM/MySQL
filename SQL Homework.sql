#MySQL Homework Assignment
SELECT *
FROM sakila.actor;
#1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;
#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
USE sakila;
SELECT CONCAT_WS(" ", first_name, last_name) AS `Actor Name` FROM actor;

SELECT *
FROM actor;
ALTER TABLE actor
DROP `Actor Name`;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
WHERE first_name LIKE ("%JOE")
;
#2b. Find all actors whose last name contain the letters GEN:
SELECT *
FROM actor a
WHERE last_name LIKE ("%GEN%")
;
#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
#Determine column types to rearrange
DESC actor;
#Alter table to rearrange the order
ALTER TABLE actor
MODIFY first_name VARCHAR(45) 
AFTER last_name;
#Display the actors with LI
SELECT *
FROM actor
WHERE last_name LIKE ("%LI%")
;
#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
DESC country;
SELECT c.country_id, c.country
FROM country c
WHERE c.country IN ("Afghanistan", "Bangladesh", "China")
;
#3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(45)
AFTER last_name
;
#Testing to see if it Middle Name column appears
SELECT *
FROM actor;
#3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
MODIFY middle_name BLOB;

SELECT *
FROM actor;
#3c. Now delete the middle_name column.
ALTER TABLE actor
DROP middle_name;
SELECT *
FROM actor;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name)
FROM actor AS Count_last_name
GROUP BY last_name
;
#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) 
FROM actor AS Count_last_name
GROUP BY last_name
#Having count will eliminate all those under 2
HAVING COUNT(last_name) >= 2
;
#4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
#the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS"
;
SELECT *
FROM actor
WHERE first_name LIKE ("%HARPO%")
;
/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the 
first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
(Hint: update the record using a unique identifier.)
*/

UPDATE actor
SET first_name = 
	CASE 
		WHEN first_name = "HARPO" AND last_name = "WILLIAMS"
		THEN "GROUCHO"
		ELSE 
        "MUCHO GROUCHO"
	END 
WHERE actor_id IN (78, 106, 172)
;

SELECT first_name, last_name, actor_id
FROM actor
WHERE actor_id IN (78, 106, 172)
;

UPDATE actor
SET first_name = "HARPO"
WHERE actor_id IN (78, 106, 172)
;
#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
CREATE TABLE address_2 LIKE address;
ALTER TABLE address_2 ADD UNIQUE(address_id);
INSERT IGNORE INTO address_2
SELECT * FROM address
ORDER BY address_id;
SET FOREIGN_KEY_CHECKS=0; 
DROP TABLE address;
SET FOREIGN_KEY_CHECKS=1;
RENAME TABLE address_2 TO address;
#6a. Use JOIN to display the first and last names, as well as the address, 
#of each staff member.  Use the tables staff and address:

#Looking at data for each table
SELECT *
FROM sakila.staff;
SELECT *
FROM sakila.address;

SELECT s.staff_id, s.first_name, s.last_name, a.address
FROM staff s
INNER JOIN address a
ON (s.address_id=a.address_id)
;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
#Use tables staff and payment.
#Looking at data from payment table
SELECT *
FROM payment;
#Inner Join payment and staff for amount rung up in August 2005
SELECT p.staff_id, SUM(p.amount) AS `Total Amount`, CONCAT(s.first_name, " ",s.last_name) AS `Staff Member`
FROM payment p
INNER JOIN staff s
ON(s.staff_id = p.staff_id)
WHERE (p.payment_date) LIKE ("2005-08%")
GROUP BY p.staff_id
;
#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
#Tables for Film Actor and Film
SELECT *
FROM film_actor;
SELECT *
FROM film;
#Build Inner Join Table of films featuring number of actors in list
SELECT f.title AS `Film Title`, COUNT(fa.actor_id) AS `Featured Actor Count`
FROM film f
INNER JOIN film_actor fa
ON(f.film_id=fa.film_id)
WHERE (fa.film_id) = (f.film_id)
GROUP BY f.film_id
;
#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
#Examine Data Featured in Necessary Tables
SELECT *
FROM inventory;
SELECT *
FROM film
WHERE title = ("Hunchback Impossible");
SELECT COUNT("Hunchback Impossible");

#Build Joins to count movie since title not featured in Inventory
SELECT f.title AS `Film Title`, COUNT(f.title) AS `Existing Copies`
FROM film f
INNER JOIN inventory i
ON(f.film_id=i.film_id)
WHERE (f.film_id) = (439)
GROUP BY f.film_id
;
#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT *
FROM payment;
DESC payment;
#Inner Join payment and customer and list alphabetically
SELECT p.customer_id AS `ID`,  c.last_name AS `Customer`, SUM(p.amount) AS `Total Amount Paid`
FROM payment p
INNER JOIN customer c
ON(c.customer_id = p.customer_id)
GROUP BY p.customer_id
ORDER BY c.last_name
;
#![Total amount paid](Images/total_payment.png)
#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
#Examine data from Databases film and language
SELECT *
FROM film;

SELECT *
FROM language;
#Build subquery of English Films with Q and K
SELECT title
FROM film
WHERE language_id IN(
SELECT language_id
FROM language 
WHERE name = ("English") AND title LIKE("K%") OR title LIKE("Q%")
);
#7b. Use subqueries to display all actors who appear in the film Alone Trip.
#Search Database Actor and Film and film_actor
SELECT * 
FROM actor;
SELECT * 
FROM film
WHERE title = "Alone Trip";
SELECT * 
FROM film_actor;
#Build subquery for actors in Alone Trip
SELECT last_name
FROM actor
WHERE actor_id IN(
SELECT actor_id
FROM film_actor
WHERE film_id IN(
SELECT film_id
FROM film
WHERE film_id = 17
));
#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
#Pull databases of Customers Address, City, Country
SELECT *
FROM customer;
SELECT *
FROM address;
SELECT *
FROM city;
SELECT *
FROM country;

SELECT CONCAT(cu.first_name, " ", cu.last_name) AS `Customer`, cu.email, co.country
FROM customer cu
INNER JOIN address a
ON (cu.address_id = a.address_id)
INNER JOIN city ci
ON (ci.city_id = a.city_id)
INNER JOIN country co
ON (co.country_id=ci.country_id)
GROUP BY cu.address_id
HAVING country = "Canada"
;
#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
#Use Views Table called nice_but_slower_film_list
SELECT title, category
FROM sakila.nicer_but_slower_film_list
WHERE category LIKE("%family%");
#7e. Display the most frequently rented movies in descending order.

#7f. Write a query to display how much business, in dollars, each store brought in.

#7g. Write a query to display for each store its store ID, city, and country.

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

/*
8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

8b. How would you display the view that you created in 8a?

8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

*/