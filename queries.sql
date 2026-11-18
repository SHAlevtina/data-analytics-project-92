-- Подсчет общего количества покупателей из таблицы
select count(customer_id) as customers_count
from customers;

-- Топ-10 лучших продавцов по выручке
-- seller — имя и фамилия продавца
-- operations — количество проведенных сделок
-- income — суммарная выручка продавца за все время
select
    e.first_name || ' ' || e.last_name as seller,
    count(*) as operations,
    floor(sum(s.quantity * p.price)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    e.first_name,
    e.last_name
order by income desc
limit 10;

-- Продавцы, чья средняя выручка за сделку меньше средней
-- выручки за сделку по всем продавцам
-- Таблица отсортирована по выручке по возрастанию
-- seller — имя и фамилия продавца
-- average_income — средняя выручка продавца за сделку
with sales_deals as (
    select
        e.employee_id,
        e.first_name || ' ' || e.last_name as seller,
        s.quantity * p.price as deal_income
    from sales as s
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
)

select
    sd1.seller,
    floor(avg(sd1.deal_income)) as average_income
from sales_deals as sd1
group by
    sd1.employee_id,
    sd1.seller
having
    floor(avg(sd1.deal_income)) < (
        select avg(sd2.deal_income)
        from sales_deals as sd2
    )
order by average_income asc;

-- Выручка по дням недели
-- seller — имя и фамилия продавца
-- day_of_week — название дня недели на английском языке
-- income — суммарная выручка продавца в день недели
select
    e.first_name || ' ' || e.last_name as seller,
    trim(to_char(s.sale_date, 'day')) as day_of_week,
    floor(sum(s.quantity * p.price)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    e.employee_id,
    extract(isodow from s.sale_date),
    trim(to_char(s.sale_date, 'day'))
order by
    extract(isodow from s.sale_date) asc,
    seller asc;

-- Количество покупателей в разных возрастных группах
select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+'
    end as age_category,
    count(*) as age_count
from customers
group by age_category
order by age_category asc;

-- Количество уникальных покупателей и выручка, которую они принесли
-- selling_month — дата в указанном формате ГОД-МЕСЯЦ
-- total_customers — количество покупателей
-- income — принесенная выручка
select
    to_char(s.sale_date, 'YYYY-MM') as selling_month,
    count(distinct s.customer_id) as total_customers,
    floor(sum(s.quantity * p.price)) as income
from sales as s
inner join products as p
    on s.product_id = p.product_id
group by selling_month
order by selling_month asc;

-- Покупатели, первая покупка которых была в ходе проведения акций
-- customer — имя и фамилия покупателя
-- sale_date — дата покупки
-- seller — имя и фамилия продавца
with first_purchases as (
    select
        s.customer_id,
        s.sale_date,
        p.price,
        c.first_name || ' ' || c.last_name as customer,
        e.first_name || ' ' || e.last_name as seller,
        row_number() over (
            partition by s.customer_id
            order by s.sale_date asc
        ) as rn
    from sales as s
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
    inner join customers as c
        on s.customer_id = c.customer_id
)

select
    customer,
    sale_date,
    seller
from first_purchases
where
    rn = 1
    and price = 0
order by customer_id asc;
