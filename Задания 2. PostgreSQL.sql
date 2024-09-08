/*
Написал: Ибрагимов Ринат Динарович
Дата: 26.08.2024
Комментарий: Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания.
*/

select 
c.last_name || ' ' || first_name as "ФИ", 
a.address,
ci.city,
co.country
from customer as c
LEFT OUTER join
address as a
on
c.address_id=a.address_id
LEFT OUTER join
city as ci
on
a.city_id =ci.city_id 
LEFT OUTER join
country as co
on
ci.country_id =co.country_id 
order by
c.last_name 

/*
Написал: Ибрагимов Ринат Динарович
Дата: 26.08.2024
Комментарий: Задание 1. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
•	Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. 
•	Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём. 
*/

select
cu.store_id as "Магазины",
count(*) as "Количество покупателей",
c.city as "Город магазина",
sta.first_name || ' ' || sta.last_name as "Продавец"
from
customer as cu
LEFT OUTER join
store as sto
on
cu.store_id=sto.store_id
LEFT OUTER join
staff as sta
on
sto.store_id=sta.store_id
LEFT OUTER join
address as a
on
sta.address_id=a.address_id
LEFT OUTER join
city as c
on
a.city_id=c.city_id
group by cu.store_id, c.city, sta.first_name, sta.last_name
having count(cu.store_id) > 300
order by 
cu.store_id
asc 

/*
Написал: Ибрагимов Ринат Динарович
Дата: 26.08.2024
Комментарий: Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов.
*/

select
c.last_name || ' ' || c.first_name as "AB",
count(r.rental_id) as "Количество фильмов"
from 
customer as c 
LEFT OUTER join
rental as r
on
r.customer_id = c.customer_id
group by c.customer_id
order by
count(rental_id)
desc
limit 5

/*
Написал: Ибрагимов Ринат Динарович
Дата: 26.08.2024
Комментарий: Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:
•	количество взятых в аренду фильмов;
•	общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
•	минимальное значение платежа за аренду фильма;
•	максимальное значение платежа за аренду фильма.
*/

select
c.last_name || ' ' || c.first_name as "ФИ",
count(r.rental_id) as "Количество фильмов",
round(sum(p.amount)) as "Общая стоимость платежей",
min(p.amount) as "Минимальное значение платежа",
max(p.amount) as "Максимальное значение платежа"
from 
customer as c 
LEFT OUTER join
rental as r 
on
r.customer_id = c.customer_id
LEFT OUTER join
payment as p
on
r.customer_id =  p.customer_id
and
p.rental_id = r.rental_id 
group by c.customer_id

/*
Написал: Ибрагимов Ринат Динарович
Дата: 26.08.2024
Комментарий: Задание 5. Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так, 
чтобы в результате не было пар с одинаковыми названиями городов. Для решения необходимо использовать декартово произведение.
*/

select 
c.city as "Первый город", 
c1.city as "Второй город"
from 
city as c
cross join
city c1
where
(c.city <> c1.city)

/*
Написал: Ибрагимов Ринат Динарович
Дата: 26.08.2024
Комментарий: Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и дате возврата (поле return_date), 
вычислите для каждого покупателя среднее количество дней, за которые он возвращает фильмы.
*/

select
r.customer_id as "ID покупателя",
round(avg(date_part('day', return_date - rental_date::date))::numeric, 2) as "среднее количество дней, за которые он возвращает фильмы"
from 
rental as r
group by 
r.customer_id
order by 
r.customer_id 

/*
Написал: Ибрагимов Ринат Динарович
Дата: 26.08.2024
Комментарий: Задание 7. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.
*/

select
f.title,
count(r.customer_id) as "Сколько раз брали в аренду",
sum(p.amount) as "Общая стоимость аренды фильма"
from film as f
LEFT OUTER join
inventory as i
on
f.film_id=i.film_id 
LEFT OUTER join
rental as r
on
i.inventory_id=r.inventory_id 
LEFT OUTER join
payment as p
on
r.rental_id=p.rental_id 
group by 
f.title
order by 
f.title 

/*
Написал: Ибрагимов Ринат Динарович
Дата: 26.08.2024
Комментарий: Задание 8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы,
которые ни разу не брали в аренду.
*/

select
f.title,
count(r.customer_id) as "Сколько раз брали в аренду",
sum(p.amount) as "Общая стоимость аренды фильма"
from film as f
LEFT OUTER join
inventory as i
on
f.film_id=i.film_id 
LEFT OUTER join
rental as r
on
i.inventory_id=r.inventory_id 
LEFT OUTER join
payment as p
on
r.rental_id=p.rental_id 
where
r.customer_id is null
group by 
f.title
order by 
"Сколько раз брали в аренду"
asc 

/*
Написал: Ибрагимов Ринат Динарович
Дата: 26.08.2024
Комментарий: Задание 9. Посчитайте количество продаж, выполненных каждым продавцом.
Добавьте вычисляемую колонку «Премия».
Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».
*/

SELECT
s.first_name || ' ' || s.last_name AS "Продавец",
COUNT(1) AS "Продажи",
CASE
WHEN COUNT(1) > 7300 THEN 'Да'
ELSE 'No'
END AS "Премия"
FROM payment p 
JOIN 
staff s 
ON 
p.staff_id = s.staff_id 
GROUP BY 
s.first_name,
s.last_name,
p.staff_id

