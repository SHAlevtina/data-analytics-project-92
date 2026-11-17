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
