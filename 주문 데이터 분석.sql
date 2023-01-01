--2021년 6월 1일 하루동안의 주문 건
--실제 존재하는 패션 이커머스 데이터라고 생각하고 분석을 진행

--1. 데이터 탐색--------------------------------------------------------------

--a) 주문 테이블
select *
from online_order

--b) 상품 테이블
select *
from item

--c) 카테고리 테이블
select *
from category

--d) 유저 테이블
select *
from user_info

--2. TOP 상품의 매출 확인--------------------------------------------------------------

--상품별 매출액 집계 후, 매출액 높은 순으로 정렬하기
select itemid, sum(gmv) as gmv
from online_order oo
group by 1
order by 2 desc;

--상품이름을 상품ID와 나란히 놓아서 한눈에 상품별 매출액을 확인할 수 있도록 하자.
select i.id, i.item_name, sum(oo.gmv) as gmv
from item i , online_order oo 
where i.id = oo.itemid
group by 1, 2
order by 3 desc;

select item_name , sum(gmv) as gmv
from online_order oo 
join item i on oo.itemid  = i.id
group by 1
order by 2 desc;

--추가질문: 카테고리별 매출액은 어떻게 될까?
--Join 테이블에 Join을 한번더
select c.cate1, c.cate2, c.cate3 ,sum(gmv) gmv
from online_order oo 
join item i on oo.itemid = i.id
join category c on i.category_id = c.id
group by 1, 2, 3
order by 4 desc;

--3. 구매고객의 성연령 분석--------------------------------------------------------------
select ui.gender , ui.age_band , sum(gmv) gmv
from online_order oo 
left join user_info ui on oo.userid = ui.userid 
group by 1, 2
order by 3 desc;

--추가질문: 남성이 구매하는 아이템은 어떤 것이 있을까?
select item_name, sum(gmv) gmv
from online_order oo 
join user_info ui on oo.userid = ui.userid
join item i on oo.itemid = i.id 
where ui.gender = 'M'
group by 1;
