Table Name-Credit_Card.

1)
write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends.
 
with temp as
(
SELECT City, 
sum(Amount) as total_spent_citywise
FROM credit_card
group by City
order by total_spent_citywise desc
)
select *,
sum(total_spent_citywise) over() as total_amount,
((total_spent_citywise)/(sum(total_spent_citywise) over())*100) as percentage_contribution_of_cc_spends
from temp
order by total_spent_citywise desc limit 5 ;


2)
write a query to print highest spend month and amount spent in that month for each card type.

with temp1 as
(
select card_type,year(date),monthname(date),sum(amount) as total_amount
from credit_card 
group by card_type,monthname(date),year(date)
),
temp2 as
(
select *,
dense_rank() over(partition by card_type order by total_amount desc) as rnk
from temp1
)
select * from temp2 where rnk=1;

3)
write a query to print the transaction details (all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends (result should have 4 rows in the o/p- one transation detail for each card type).

with temp1 as
(
select *,
sum(Amount) over(partition by Card_Type order by amount)as cumulative_sum 
from credit_card
),
temp2 as 
(
select *, dense_rank() 
over(partition by Card_Type 
order by cumulative_sum) as rnk 
from temp1 
where cumulative_sum >=1000000
)
select * from temp2 where rnk =1 ;


4)
write a query to find city which had lowest percentage spend for gold card type .

with temp1 as
(
select city,sum(amount) as total_gold_spent
from credit_card
where card_type="gold"
group by city
),
temp2 as
(
select city,sum(amount) as total_spent
from credit_card
group by city
),
temp3 as
(
select temp1.City,
temp1.total_gold_spent,
temp2.total_spent,
(temp1.total_gold_spent/temp2.total_spent)*100 as perc_contri
from temp1 
inner join temp2 on temp1.City = temp2.City
)
select * from temp3
order by perc_contri limit 1;


5)
Find -: highest_expense_type , lowest_expense_type for all the cities (example format : kolkata , bills, Fuel)?

with temp1 as
(
select city,exp_type,
dense_rank() over(partition by city order by sum(amount) asc ) as kom
from credit_card
group by exp_type,city
),
temp2 as 
(
select city,exp_type,
dense_rank() over(partition by city order by sum(amount) desc) as som
from credit_card
group by exp_type,city
)
select t1.city,t1.exp_type,t2.exp_type from 
temp1 t1
join temp2 t2
on t1.city=t2.city
where kom<2 and som<2;

6)
write a query to find percentage contribution of spends by females for each expense type .

with temp1 as
(
select exp_type,sum(amount) as total_spent_female
from credit_card
where gender="f"
group by exp_type
),
temp2 as
(
select exp_type,sum(amount) as total_spent
from credit_card
group by exp_type
)
select t1.exp_type,t1.total_spent_female,t2.total_spent,
(t1.total_spent_female/t2.total_spent)*100 as per_contri
from temp1 t1
join temp2 t2
on t1.exp_type=t2.exp_type
;

7)
which card and expense type combination saw highest month over month growth in Jan-2014 .

with temp1 as
(
select card_type,exp_type,monthname(date) as m_name,year(date) as years,sum(amount) as amt_mnth
from credit_card
group by card_type,exp_type,years,m_name
),
temp2 as
(
select *,
lag(amt_mnth) over(partition by card_type,exp_type order by years,m_name) as lag_amnt
from temp1
)
select *,
(amt_mnth-lag_amnt) as mom_growth
from temp2
where m_name="january" and years=2014
order by mom_growth desc limit 1;

8)
During weekends which city has highest total spend to total no of transactions ratio ?

select city,sum(amount) as amt_spent_on_weekend,count(*) as no_of_tran_weekend,
(sum(amount)/count(*)) as ratio
from credit_card
where weekday(date) in (5,6)
group by city
order by ratio desc limit 1;












