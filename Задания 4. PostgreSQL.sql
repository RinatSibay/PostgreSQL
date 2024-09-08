/*
Написал: Ибрагимов Ринат Динарович
Дата: 08.09.2024
Комментарий: Задание 1. Напишите SQL-запрос, который выводит всю информацию о фильмах
 со специальным атрибутом (поле special_features)
 равным “Behind the Scenes”.
*/

select 
*
from
film
where 
special_features = '{"Behind the Scenes"}'

/*
Написал: Ибрагимов Ринат Динарович
Дата: 08.09.2024
Комментарий: Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, 
используя другие функции или операторы языка SQL для поиска значения в массиве.
*/

select 
*
from 
film
where 'Behind the Scenes' = any (special_features)

/*
Написал: Ибрагимов Ринат Динарович
Дата: 08.09.2024
Комментарий: Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов 
со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в CTE.
*/

with 
customers_films as 
(
select distinct  
r.customer_id as "Покупатель",
count(f.film_id) over (partition by r.customer_id ) as "Количество фильмов"
from 
film as f 
inner join 
inventory as i 
on 
i.film_id = f.film_id
inner join 
rental as r 
on 
r.inventory_id = i.inventory_id
where 
special_features = '{"Behind the Scenes"}'
order by
r.customer_id
)
select 
*
from 
customers_films

/*
Написал: Ибрагимов Ринат Динарович
Дата: 08.09.2024
Комментарий: Задание 4. Для каждого покупателя посчитайте, 
сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1,
 помещённый в подзапрос, который необходимо использовать для решения задания.
*/

select distinct 
r.customer_id as "Покупатель",
count(f.film_id) over (partition by r.customer_id ) as "Количество фильмов"
from 
film as f 
inner join inventory i on i.film_id = f.film_id
inner join rental r on r.inventory_id = i.inventory_id
where
f.film_id in (select f2.film_id from film f2 where f2.special_features = '{"Behind the Scenes"}') 
order by 
r.customer_id
