-- Подсчет общего количества покупателей из таблицы
select 
count(customer_id) customers_count
from customers
;

-- Топ-10 лучших продавцов
    -- seller — имя и фамилия продавца
    -- operations - количество проведенных сделок
    --income — суммарная выручка продавца за все время

select
e.first_name || ' ' || e.last_name as seller,
count(*) as operations,
FLOOR(sum(s.quantity * p.price)) as income
from sales s 
join employees e on 
s.sales_person_id  = e.employee_id 
join products p on
p.product_id = s.product_id
group by e.employee_id, e.first_name, e.last_name 
order by income desc
limit 10
;

-- Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
--Таблица отсортирована по выручке по возрастанию.
    -- seller — имя и фамилия продавца
    -- average_income — средняя выручка продавца за сделку с округлением до целого

with sumalls as (
    select
        e.employee_id,
        e.first_name || ' ' || e.last_name as seller,
        s.quantity * p.price as sumall_income
    from sales s
    join employees e on s.sales_person_id = e.employee_id
    join products p on p.product_id = s.product_id
)
select
    seller,
    floor(avg(sumall_income)) as average_income
from sumalls
group by employee_id, seller
having floor(avg(sumall_income)) < (
    select avg(sumall_income)
    from sumalls
)
order by average_income asc;
