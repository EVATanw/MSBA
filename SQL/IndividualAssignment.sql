/*
An6005 Class Exercise 1
Name: Tan Yixian
Matric NO: G2401043F
*/

/* Q1 Table considered: <customerTBL> 
How many customers are there? */

select count(KFlyerID) as 'CustAmount_Total'
from customertbl;

/* Q2 Table considered: < customerTBL >
What are the membership types? */

select distinct trim(MembershipType) as 'MembershipTypes'
from customertbl;

/* Q3 Table considered: < customerTBL > 
For each membership type, how many customers are there? */

select trim(MembershipType) as MembershipType, count(KFlyerID) as CustAmount_perType
from customertbl
group by MembershipType;

/* Q4 Tables considered: <customerTBL> + < postalsectTBL> 
For each GeneralLoc, on each membership type, display the total number of customers, and the respective breakdowns between females and males */

select 
	postalsecttbl.GeneralLoc as GeneralLoc, 
	trim(customertbl.MembershipType) as MembershipType, 
	count(customertbl.KFlyerID) as CustAmt_Total,
    sum(case when customertbl.CustGen = 'FEMALE' then 1 else 0 end) as CustAmt_Female,
    sum(case when customertbl.CustGen = 'MALE' then 1 else 0 end) as CustAmt_Male
from customertbl, postalsecttbl
where customertbl.PostalSect = postalsecttbl.PostalSect
group by postalsecttbl.GeneralLoc, trim(customertbl.MembershipType)
order by GeneralLoc, MembershipType;


/* Q5 Tables considered: < customerTBL> + < postalsectTBL> 
For each general location, on each membership type, display the number of customers who have been members since 2000. */

select 
	postalsecttbl.GeneralLoc as GeneralLoc, 
    trim(customertbl.MembershipType) as MembershipType, 
    count(customertbl.KFlyerID) as CustAmt_2000
from customertbl, postalsecttbl
where customertbl.PostalSect = postalsecttbl.PostalSect and MemeberSince_y = 2000
group by postalsecttbl.GeneralLoc, trim(customertbl.MembershipType)
order by GeneralLoc, MembershipType;

/* Q6 Tables considered: < customerTBL> + < TripTBL> + <destTBL>
For each membership type, display the total trip distance (among members with the same membership type) for trips completed between the year 2020 and 2022. */

select 
	trim(customertbl.MembershipType) as MembershipType, 
    sum(desttbl.Dist) as TripDistance_2020_2022
from
	desttbl, 
    customertbl,
    (select * from tripstbl where Trip_y between 2020 and 2022) as tripstbl2
where customertbl.KFlyerID = tripstbl2.KFlyerID and tripstbl2.RouteID = desttbl.DestID
group by trim(customertbl.MembershipType)
order by MembershipType;

/* Q7 Tables considered: <TripTBL> + <destTBL>
Who are the top travelers during holiday seasons (i.e., July, August, November, and December) and non-holiday seasons (i.e., remaining months)?
Using a single result grid, display the top two travelers (total longest trip distance) for the holiday and non-holiday seasons, respectively. 
You should only consider outbound flights. 
You should not consider trips going to NRT, MAN, and LGW. */
select *
from (
	select tripstbl.KFlyerID as KFlyerID, desttbl.AirCode as AirCode, count(tripstbl.TripID) as TripAmt, sum(desttbl.Dist) as totalDistance
	from desttbl, tripstbl
	where 
		tripstbl.RouteID = desttbl.DestID and
        tripstbl.Trip_m in (7, 8, 11, 12) and 
        tripstbl.Outbound = 1 and
        desttbl.AirCode not like '%NRT%' and desttbl.AirCode not like '%MAN%' and desttbl.AirCode not like '%LGW%'
	group by tripstbl.KFlyerID, desttbl.AirCode
	order by sum(desttbl.Dist) desc, tripstbl.KFlyerID
	limit 2
) as result_holiday

union all

select *
from (
	select tripstbl.KFlyerID as KFlyerID, desttbl.AirCode as AirCode, count(tripstbl.TripID) as TripAmt, sum(desttbl.Dist) as totalDistance
	from desttbl, tripstbl
	where 
		tripstbl.RouteID = desttbl.DestID and
        tripstbl.Trip_m not in (7, 8, 11, 12) and 
        tripstbl.Outbound = 1 and
        desttbl.AirCode not like '%NRT%' and desttbl.AirCode not like '%MAN%' and desttbl.AirCode not like '%LGW%'
	group by tripstbl.KFlyerID, desttbl.AirCode
	order by sum(desttbl.Dist) desc, tripstbl.KFlyerID
	limit 2
) as result_noholiday;


/* Q8 Tables considered: <fullogTBL> + < customerTBL >
Which membership type is the most frequent chatbot user?
For each membership type, display the number of sustained conversations (i.e., a sustained conversation involves more than 1 customer-chatbot exchange in a conversation instance). */

select trim(customertbl.MembershipType) as MembershipType, count(chatfreq) as frequency
from 
	(
	select UserID, Date_d, Date_m, Date_y, count(*) as chatfreq
    from fulllogtbl
    group by UserID, Date_d, Date_m, Date_y
    having count(*)>1
    ) as fulllogtbl2,
    customertbl
where 
	fulllogtbl2.UserID = customertbl.KFlyerID and 
	customertbl.MembershipType is not null
group by trim(customertbl.MembershipType)
order by frequency desc;

/* Q9 Tables considered: <tripsTBL> + <destTBL> + <fulllogTBL> + <customerTBL>
Customer Analytics. You may present the final output in the following format.
Your results may differ. Do provide your assumptions (if any) in the inline comments. */

#i. Generate a list of userid, and the corresponding averages of joy, anger, disgust, surprise, fear, sadness, contempt, sentimentality, confusion.
select 
	UserID, 
    avg(Joy),
    avg(Anger),
    avg(Disgust),
    avg(Surprise),
    avg(Fear),
    avg(Sadness),
    avg(Contempt),
    avg(Sentimentality),
    avg(Confusion)
from fulllogtbl
group by UserID;

#ii. Generate a list of KFlyerID and the corresponding modified miles (Dist * EliteMilesMod).
select 
	KFlyerID,
    sum(tripstbl.EliteMilesMod * desttbl.Dist) as modified_moiles 
from tripstbl
join desttbl on tripstbl.RouteID = desttbl.DestID
group by KFlyerID;

# iii. Combine (1) and (2) based on a logical condition.
# iv. Generate a list of KFlyerID and the corresponding Positive Emotions (averages of Joy, generated above), Negative Emotions (averages of Anger + Disgust + Fear + Sadness), Sentimentality (generated above), and Confusion (generated above).
# v. Generate a list of KFlyerID and the corresponding ratios. Specifically,
# Positive Emotions Ratio = log (Positive Emotions) / log (modified miles)
# Negative Emotions Ratio = log (Negative Emotions) / log (modified miles)
# Sentimentality Ratio = log (Sentimentality) / log (modified miles)
# Confusion Ratio = log (confusion) / log (modified miles)
select
	kflyerid_mile.KFlyerID,
    log( avg(user_emo.p_j) ) / log(kflyerid_mile.modified_miles) as p_radio,
	log( avg(user_emo.n_a + user_emo.n_d + user_emo.n_f + user_emo.n_s) ) / log(kflyerid_mile.modified_miles) as n_radio,
    log( avg(user_emo.s_s) ) / log(kflyerid_mile.modified_miles) as s_radio,
    log( avg(user_emo.c_c) ) / log(kflyerid_mile.modified_miles) as c_radio
from (
	select 
	UserID, 
    avg(Joy) as p_j,
    avg(Anger) as n_a,
    avg(Disgust) as n_d,
    avg(Surprise),
    avg(Fear) as n_f,
    avg(Sadness) as n_s,
    avg(Contempt),
    avg(Sentimentality) s_s,
    avg(Confusion) as c_c
	from fulllogtbl
	group by UserID
	) as user_emo,
    (select 
		KFlyerID,
		sum(tripstbl.EliteMilesMod * desttbl.Dist) as modified_miles
	from tripstbl
	join desttbl on tripstbl.RouteID = desttbl.DestID
	group by KFlyerID
	) as kflyerid_mile
where user_emo.UserID = kflyerid_mile.KFlyerID
group by kflyerid_mile.KFlyerID;

# vi. Retrieve records satisfying the following conditions:
# Positive Emotions Ratio > Negative Emotions Ratio AND
# Positive Emotions Ratio > Sentimentality Ratio AND
# Positive Emotions Ratio > Confusion Ratio
# The number of records is the number of “Happy Customers”.
# Repeat (vi) for each of the following conditions.
# [Upset Customers]
# Negative Emotions Ratio > Positive Emotions Ratio AND
# Negative Emotions Ratio > Sentimentality Ratio AND
# Negative Emotions Ratio > Confusion Ratio
# [Sentimental Customers]
# Sentimentality Ratio > Positive Emotions Ratio AND
# Sentimentality Ratio > Negative Emotions Ratio AND
# Sentimentality Ratio > Confusion Ratio
# [Confused Customers]
# Confusion Ratio > Positive Emotions Ratio AND
# Confusion Ratio > Negative Emotions Ratio AND
# Confusion Ratio > Sentimentality Ratio
with customerType as (
	with kflyerid_radio as (
		select
			kflyerid_mile.KFlyerID,
			log( user_emo.p_j ) / log(kflyerid_mile.modified_miles) as p_radio,
			log( (user_emo.n_a + user_emo.n_d + user_emo.n_f + user_emo.n_s)/4 ) / log(kflyerid_mile.modified_miles) as n_radio,
			log( user_emo.s_s ) / log(kflyerid_mile.modified_miles) as s_radio,
			log( user_emo.c_c ) / log(kflyerid_mile.modified_miles) as c_radio
		from (
			select 
				UserID, 
				avg(Joy) as p_j,
				avg(Anger) as n_a,
				avg(Disgust) as n_d,
				avg(Surprise),
				avg(Fear) as n_f,
				avg(Sadness) as n_s,
				avg(Contempt),
				avg(Sentimentality) s_s,
				avg(Confusion) as c_c
			from fulllogtbl
			group by UserID
		) as user_emo,
        (
			select 
				KFlyerID,
				sum(tripstbl.EliteMilesMod * desttbl.Dist) as modified_miles
			from tripstbl
			join desttbl on tripstbl.RouteID = desttbl.DestID
			group by KFlyerID
		) as kflyerid_mile
		where user_emo.UserID = kflyerid_mile.KFlyerID
		group by kflyerid_mile.KFlyerID
	)

	select
		CASE
			WHEN p_radio > n_radio AND p_radio > s_radio AND p_radio > c_radio THEN 'Happy Customers'
            WHEN n_radio > p_radio AND n_radio > s_radio AND n_radio > c_radio THEN 'Upset Customers'
            WHEN s_radio > p_radio AND s_radio > n_radio AND s_radio > c_radio THEN 'Sentimental Customers'
            WHEN c_radio > p_radio AND c_radio > n_radio AND c_radio > s_radio THEN 'Confused Customers'
        END AS CustomerType
	from kflyerid_radio
)
    
(select 
	'Happy Customer' as CustomerType, count('Happy Customers') as CustomerCount
from customerType
where CustomerType = 'Happy Customers')
union
(select 
	'Upset Customer' as CustomerType, count('Upset Customers') as CustomerCount
from customerType
where CustomerType = 'Upset Customers')
union
(select 
	'Sentimental Customer' as CustomerType, count('Sentimental Customers') as CustomerCount
from customerType
where CustomerType = 'Sentimental Customers')
union
(select 
	'Confused Customer' as CustomerType, count('Confused Customers') as CustomerCount
from customerType
where CustomerType = 'Confused Customers');



/* Q10 Tables considered: <FulllogTBL> 
MySQL SOUNDEX() function returns soundex string of a string.
SOUNDEX is a phonetic algorithm for indexing names after the English pronunciation of sound. For details, see https://dev.mysql.com/doc/refman/8.4/en/string-functions.html#function_soundex
Audio Analytics. Using SOUNDEX(), identify the most frequent soundex string (4 rightmost characters) from the content column (i.e., 1423).
Display records with the content column containing the soundex string (i.e., %1423%). */
select *
from 
	fulllogtbl
where SOUNDEX(Content) like (
	select concat('%',soundex_f.soundex,'%')
    from (
		select right(SOUNDEX(Content),4) as soundex
		from fulllogtbl
		group by right(SOUNDEX(Content),4)
		order by count(*) desc
		limit 1
	) as soundex_f
);
    





















