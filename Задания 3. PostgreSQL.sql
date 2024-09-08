/*
Написал: Ибрагимов Ринат Динарович
Дата: 26.08.2024
Комментарий: Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций до-бавьте вычисляемые колонки согласно условиям:
•	Пронумеруйте все платежи от 1 до N по дате
•	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
•	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
•	Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в од-ном запросе.
*/

select
customer_id as "id Покупателя",
payment_date as "дата платежа",
row_number() over (order by payment_date) as "Номер платежа по дате",
row_number() over (partition by customer_id order by payment_date) as "Номер платежа поку-пателя по дате",
sum(p.amount) over (partition by p.customer_id order by p.payment_date)
FROM 
payment as p

/*
Написал: Ибрагимов Ринат Динарович
Дата: 31.08.2024
Комментарий: Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость платежа
 из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
*/

 select 
 customer_id,
 payment_date,
 amount,
 lag(p.amount,1,0.) over (partition by customer_id order by p.payment_date)
 from 
 payment p
 order by
 customer_id
 
/*
Написал: Ибрагимов Ринат Динарович
Дата: 31.08.2024
Комментарий: Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж
 покупателя больше или меньше текущего.
*/
 
select
customer_id as "ID покупателя",
payment_id as "ID оплаты", 
payment_date as "дата покупки",
amount as "цена",
amount - lead(p.amount,1,0.) over (partition by customer_id  order by p.payment_date, customer_id) as "> или <"
from 
payment as p

/*
Написал: Ибрагимов Ринат Динарович
Дата: 31.08.2024
Комментарий: Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
*/

select 
customer_id as "id покупателя",
payment_id as "id покупки", 
payment_date as "Дата оплаты ", 
last_value as "Поледняя оплата аренды"
from(
	select 
	customer_id,
	payment_id,
	payment_date,
		last_value(amount) over (partition by customer_id order by payment_date desc),
		row_number() over (partition by customer_id order by payment_date desc) 
	from 
	payment) p 
where 
row_number = 1

/*
Написал: Ибрагимов Ринат Динарович
Дата: 08.09.2024
Комментарий: Задание 5. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года
 с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.
*/

select 
staff_id as "Продавец",
customer_id as "Покупатель", 
payment_date::date as "Дата покупки",
sum as "Цена",
sum(sum) over (partition by staff_id order by staff_id, payment_date::date) as "Нарастающий итог по датам",
sum(sum) over (partition by staff_id order by staff_id) as "Сумма продаж за август"
from 
	(select 
	staff_id,
	customer_id, 
	payment_date::date,
	sum(amount)
	 from 
	 payment 
	 where 
	 date_part('month', payment_date::date) = 8
	 group by 
	 customer_id, 
	 staff_id,
	 payment_date::date
	 order by payment_date) t

/*
Написал: Ибрагимов Ринат Динарович
Дата: 08.09.2024
Комментарий: Задание 6. 20 августа 2005 года в магазинах проходила акция:
 покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду. 
 С помощью оконной функции выведите всех покупателей, которые в день проведения акции полу-чили скидку.
*/
select 
customer_id as "Покупатель",
payment_date as "Дата",
row_number as "100 покупатель"
from 
	(select
	customer_id,
	payment_date, 
	row_number() over (order by payment_date)
	from
	payment
	where
	payment_date::date = '2005-08-20') t
where 
row_number % 100 = 0

/*
Написал: Ибрагимов Ринат Динарович
Дата: 08.09.2024
Комментарий: Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
покупатель, арендовавший наибольшее количество фильмов;
покупатель, арендовавший фильмов на самую большую сумму;
покупатель, который последним арендовал фильм.
*/

select 
t.country as "Страна",
group_concat(case 
when max_count = 1 then t.nickname
end) as "покупатель, арендовавший наибольшее количество фильмов",
group_concat(case 
when max_amount = 1 then t.nickname
end) as "покупатель, арендовавший фильмов на самую большую сумму",
group_concat(case 
when latest_rent = 1 then t.nickname
end) as "покупатель, который последним арендовал фильм"
from 
(select 
co.country_id,
co.country,
cu.customer_id, 
concat(cu.first_name,' ', cu.last_name) as nickname,
count(r.rental_id),
sum(p.amount), 
max(r.rental_date),
rank() over (partition by co.country_id order by count(r.rental_id) desc) as max_count,
rank() over (partition by co.country_id order by sum(p.amount) desc) as max_amount,
rank() over (partition by co.country_id order by max(r.rental_date) desc) as latest_rent
from
country co 
left join city ci on co.country_id = ci.country_id 
left join address a on a.city_id = ci.city_id 
left join customer cu on cu.address_id = a.address_id 
join rental r on cu.customer_id = r.customer_id 
left join payment p on p.rental_id = r.rental_id 
group by 
cu.customer_id, co.country_id, co.country) t
group by t.country_id, t.country


