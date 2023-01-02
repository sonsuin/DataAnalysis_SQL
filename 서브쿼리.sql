-- 1. 하루동안 2개 이상의 상품을 구매한 고객은 주로 어떤 상품을 구매했을까?
-- 1 Depth : 하루동안 2개 이상의 상품을 구매한 고객
select oo.userid 
from online_order oo 
join user_info ui on oo.userid = ui.userid
group by 1
having count(distinct itemid) >=2; 

--2 Depth : 어떤 상품을 구매했을까?
select cate3, item_name, price
from online_order oo 
join item i on oo.itemid = i.id 
join category c on i.id = c.id 
join(select oo.userid 
	 from online_order oo 
	 join user_info ui on oo.userid = ui.userid
	 group by 1
	 having count(distinct itemid) >=2) user_list on oo.userid = user_list.userid
group by 1, 2, 3
order by 3 desc;



-- 2. A 상품을 구매한 고객은 A상품 외에 추가로 어떤 상품을 구매했을까?
--1 Depth : A상품을 구매한 고객
select oo.userid
from online_order oo 
join user_info ui on oo.userid = ui.userid 
join item i on oo.itemid = i.id 
where item_name = '올여름 필수템! 청반바지 필수템'

--2 Depth : A상품 외 어떤 상품을 구매했는가?
select item_name, count(distinct oo.userid) as user_cnt
from online_order oo 
join item i on oo.itemid = i.id 
join (select oo.userid
	  from online_order oo 
	  join user_info ui on oo.userid = ui.userid 
	  join item i on oo.itemid = i.id 
	  where item_name = '올여름 필수템! 청반바지 필수템') user_list on oo.userid = user_list.userid
group by 1
having item_name not in ('올여름 필수템! 청반바지 필수템');



-- 3. 하루동안 2개 이상의 상품을 구매한 고객의 성연령 분포는 어떠할까?
--1 Depth : 하루동안 2개 이상의 상품을 구매한 고객
select oo.userid
from online_order oo
join item i on oo.itemid = i.id 
group by 1
having count(distinct itemid) >= 2;

--2 Depth : 성연령 분포는?
select ui.gender, ui.age_band, count(oo.userid) user_cnt
from online_order oo
join user_info ui on oo.userid = ui.userid 
left join (select oo.userid
		   from online_order oo
		   join item i on oo.itemid = i.id 
		   group by 1
		   having count(distinct itemid) >= 2) user_list on oo.userid = user_list.userid
group by 1, 2;





