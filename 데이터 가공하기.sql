--실습 3) 주문 데이터로 데이터 가공하기 연습
--2021년 6월 1일 하루동안의 주문 건
--실제 존재하는 패션 이커머스 데이터라고 생각하고 분석을 진행


--1. 원하는 형식으로 컬럼 가공하기--------------------------------------------------------------

--a) 숫자를 문자열로 바꿔주기
select dt, cast(dt as varchar) as yyyymmdd
from online_order oo 

--b) 문자열 컬럼에서 일부만 잘라내기
select dt, 
left(cast(dt as varchar), 4) as yyyy,
substring(cast(dt as varchar), 5, 2) as mm,
right(cast(dt as varchar), 2) as dd
from online_order oo 

--c) yyyy-mm-dd 형식으로 이어주기
select dt,
concat(
left(cast(dt as varchar), 4) ,'-',
substring(cast(dt as varchar), 5, 2),'-',
right(cast(dt as varchar), 2) 
) as yyyymmdd
from online_order oo 

select dt,
left(cast(dt as varchar), 4) || '-' ||
substring(cast(dt as varchar), 5, 2) || '-' ||
right(cast(dt as varchar), 2) as yyyymmdd
from online_order oo

--d) null 값인 경우 임의값으로 바꿔주기
select oo.userid, coalesce(oo.userid, 'NA') 
from online_order oo 
left join user_info ui on oo.userid = ui.userid 
-- -> 에러 나는 이유 : oo.userid 는 숫자형이고 NA는 숫자형이 아니여서

select oo.userid, coalesce(oo.userid, 0) 
from online_order oo 
left join user_info ui on oo.userid = ui.userid 

select coalesce(ui.gender, 'NA') as gender,
coalesce(ui.age_band,'NA') as age_band,
sum(gmv) as gmv
from online_order oo 
left join user_info ui on oo.userid = ui.userid
group by 1, 2;

--e) 내가 원하는 컬럼 추가해보기
select case when gender = 'M' then '남성' 
			when gender = 'F' then '여성' 
			else 'NA' 
			end as gender
from user_info ui 

--f) 연령대 그룹 만들어보기 (20대, 30대, 40대)
select ui.age_band ,
case when ui.age_band ='20~24' then '20s'
	 when ui.age_band ='25~29' then '20s'
	 when ui.age_band ='30~34' then '30s'
	 when ui.age_band ='35~39' then '30s'
	 when ui.age_band ='40~44' then '40s'
	 when ui.age_band ='45~49' then '40s'
	 else 'NA'
	 end as age_group
from online_order oo 
left join user_info ui on oo.userid = ui.userid 
group by 1;

--g) TOP3 카테고리와 그 외 상품의 매출액 비교하기
select
case when cate1 in ('스커트', '티셔츠', '원피스') then 'TOP3'
	 else '기타'
	 end as item_type,
sum(gmv) gmv
from online_order oo 
join item i on oo.itemid = i.id 
join category c on i.category_id = c.id 
group by 1
order by 2 desc;

--h) 특정 키워드가 담긴 상품과 그렇지 않은 상품의 매출 비교하기 (+item 개수도 같이 확인!)
-- 순서 중요
select
case when item_name like '%깜찍%' then '깜찍 컨셉'
	 when item_name like '%시크%' then '시크 컨셉'
	 when item_name like '%청순%' then '청순 컨셉'
	 when item_name like '%기본%' then '기본 컨셉'
	 else '미분류'
	 end as item_concept
, sum(gmv) gmv
from online_order oo 
join item i on oo.itemid = i.id 
group by 1
order by 2 desc;


--2. 날짜 관련 함수 활용하기--------------------------------------------------------------

--a) 오늘을 나타내는 기본 구문
select now();

select current_date;

select current_timestamp; 

--b) 날짜 형식에서 문자 형식으로 변환하기
select to_char(now(), 'yyyymmdd');

select to_char(now(), 'yyyy / mm / dd');

--c) 날짜 더하기/빼기
select now() + interval '1 month';

select now() - interval '1 month';

--d 날짜로부터 연도, 월, 주 확인하기
select date_part('month', now()); 

select date_part('day', now());

--d) 최근 1년 동안의 매출액 확인하기
select * 
from gmv_trend gt 
where cast(yyyy as varchar) || cast(mm as varchar) 
>= cast(date_part('year', now() - interval '1 year') as varchar) || cast(date_part('month', now() - interval '1 year') as varchar)
order by 2, 3;


--3. 할인률, 판매가, 이익률 계산하기
-- int : 소수점 x
-- numeric : 소수점 o
select c.cate1 ,
sum(cast(discount as numeric)) / sum(gmv) as discount_rate,
sum(gmv) - sum(discount) as paid_amount,
sum(cast(product_profit as numeric)) / sum(gmv) as product_magin,
sum(cast(total_profit as numeric)) / sum(gmv) as total_margin
from online_order oo
join item i on oo.itemid = i.id 
join category c on i.category_id = c.id
group by 1
order by 3 desc;

select c.cate1 ,
round(sum(cast(discount as numeric)) / sum(gmv),2) * 100 || '%' as discount_rate,
sum(gmv) - sum(discount) as paid_amount,
round(sum(cast(product_profit as numeric)) / sum(gmv),2) * 100 || '%' as product_magin,
cast(round(sum(cast(total_profit as numeric)) / sum(gmv) * 100) as varchar) || '%' as total_margin
from online_order oo
join item i on oo.itemid = i.id 
join category c on i.category_id = c.id
group by 1
order by 3 desc;

--4. 고객 관점에서의 분석 (인당 평균 구매수량 / 인당 평균 구매금액)

--100명의 고객이 구매를 하였고, 총 판매수량이 200개
--인당 평균 구매수량 = 총 판매수량 / 총 고객 수
--인당 평균 구매금액 = 총 구매금액 / 총 고객 수
select * from online_order oo ;

--인당 구매수량이 높은 상품은?
select item_name,
sum(unitsold) as unitsold ,
count(distinct userid) as user_count,
round(sum(cast(unitsold as numeric)) / count(distinct userid),2) as avg_unitsole_per_customer
from online_order oo 
join item i on oo.itemid = i.id
group by 1
order by 4 desc;

--인당 구매금액이 높은 성/연령대는?
select age_band, gender,
sum(gmv) as gmv,
count(distinct oo.userid) as user_count,
sum(gmv)/ count(distinct oo.userid) as avg_gmv_per_customer
from online_order oo 
join user_info ui on oo.userid = ui.userid
group by 1, 2
order by 5 desc;

