// 1.	How many categories are in [customer_suppport]?
// TIP: You need to decide whether to clean up the data.
use "customer_support"
db.customer_support.find()

db.customer_support.aggregate([
    { $match: {category: {$exists: true,$ne: null,$regex: /^[A-Z]+$/}} },
    { $group: {_id: {groupByCate: "$category"}}},
]).count()


// 2.	[customer_suppport] For each category, display the number of records that contained colloquial variation and offensive language.
// TIP: Refer to language generation tags.

db.customer_support.aggregate([
    { $match: {$and: [
        {category: {$exists: true,$ne: null}}, 
        {$or: [ 
            {'flags':{$regex:/Q/}}, 
            {'flags':{$regex:/W/}} 
            ]}
            ]}},
    { $group: {_id: {groupByCate: "$category"}, number:{$sum:1}}}
])


// 3.	[flight_delay] For each airline, display the instances of cancellations and delays.
// Hint: UNION, $merge

use "flight_delay"
db.flight_delay.find()

db.flight_delay.aggregate([
    { $match:{"Cancelled":1}},
    {$group:{_id:{groupByAirline:"$Airline"},Amt:{$sum:1}}},
    {$merge:"amount"}
])

db.flight_delay.aggregate([
    {$match:{$or:[
                {CarrierDelay:{$gt:0}},
                {WeatherDelay:{$gt:0}},
                {NASDelay:{$gt:0}},
                {SecurityDelay:{$gt:0}},
                {LateAircraftDelay:{$gt:0}},
                {ArrDelay:{$gt:0}},
                {DepDelay:{$gt:0}}]}},
    {$group:{_id:{groupByAirline:"$Airline"},Amt:{$sum:1}}},
    {$merge:"amount"}
])

db.amount.find({})


// 4.	[sia_stock] For each month (of a year), display the high and low prices, total transaction volume, and daily average transaction volume.

use sia_stock
db.sia_stock.find()

db.sia_stock.aggregate([
    {$group:{
        _id:{
            month:{$dateToString: { 
                format: "%Y-%m", 
                date:{$toDate: "$StockDate"}}}},
        High:{$max:"$High"},
        Low:{$min:"$Low"},
        Vol:{ $sum:{$toDouble:{$substr: [ "$Vol", 0, {$subtract: [{$strLenCP: "$Vol"}, 1]} ]}}},
        count:{$sum:1}
    }},
    {$sort:{"_id.month":1}},
    {$project:{
        _id:0,
        month:"$_id.month",
        High:1,
        Low:1,
        TotalVol:{$concat:[{$toString: "$Vol"},"M"]},
        DailyVol:{$round:[{$divide:["$Vol","$count"]},2]}
    }}
    ])


// 5.	[sia_stock] For the year 2023, display the quarter-on-quarter changes in high and low prices and the quarterly average price.
// Note: For details on Quarter-on-Quarter, see https://www.investopedia.com/terms/q/qoq.asp

use sia_stock
db.sia_stock.find()

db.sia_stock.aggregate([
    {$match:{$expr:{$eq:[{$year:{$toDate: "$StockDate"}},2023]}}},
    {$bucket:{
        groupBy:{$month:{$toDate: "$StockDate"}},
        boundaries:[1,4,7,10,13],
        output:{
            avgHigh:{$avg:{$toDouble: "$High"}},
            avgLow:{$avg:{$toDouble: "$Low"}}
        }
    }},
    {$project:{
        quarter_name:{$switch:{branches:[
                {case:{$eq:["$_id",1]},then:"Q1"}, 
                {case:{$eq:["$_id",4]},then:"Q2"},
                {case:{$eq:["$_id",7]},then:"Q3"},
                {case:{$eq:["$_id",10]},then:"Q4"}
            ],default:"Unknown"}},
        avgHigh:1,
        avgLow:1
    }},
    {$merge:"Q2023results"}
    ])
db.Q2023results.find({})

db.sia_stock.aggregate([
    {$match:{$expr:{$eq:[{$year:{$toDate: "$StockDate"}},2024]}}},
    {$bucket:{
        groupBy:{$month:{$toDate: "$StockDate"}},
        boundaries:[1,4,7,10,13],
        output:{
            avgHigh:{$avg:{$toDouble: "$High"}},
            avgLow:{$avg:{$toDouble: "$Low"}}
        }
    }},
    {$project:{
        quarter_name:{$switch:{branches:[
                {case:{$eq:["$_id",1]},then:"Q1"}, 
                {case:{$eq:["$_id",4]},then:"Q2"},
                {case:{$eq:["$_id",7]},then:"Q3"},
                {case:{$eq:["$_id",10]},then:"Q4"}
            ],default:"Unknown"}},
        avgHigh:1,
        avgLow:1
    }},
    {$merge:"Q2024results"}
    ])
db.Q2024results.find({})

db.Q2024results.aggregate([
    {$lookup: {
        from: "Q2023results", 
        localField: "quarter_name", 
        foreignField: "quarter_name",
        as: "prevQuarterData"}},
    {$project: {
        quarter_name: 1,
        avgHigh2024: "$avgHigh",
        avgLow2024: "$avgLow",
        prevQuarterData: { $arrayElemAt: ["$prevQuarterData", 0] }}},
    {$project: {
        quarter_name: 1,
        avgHigh2024: 1,
        avgLow2024: 1,
        prevHigh: { $ifNull: ["$prevQuarterData.avgHigh", 0] }, 
        prevLow: { $ifNull: ["$prevQuarterData.avgLow", 0] }}},
    {$project: {
        quarter_name: 1,
        avgHigh2024: 1,
        avgLow2024: 1,
        highGrowthRate: {
            $cond: {
                if: { $eq: ["$prevHigh", 0] }, then: 0, 
                    else: { $multiply: [{ $divide: [{ $subtract: ["$avgHigh2024", "$prevHigh"] }, "$prevHigh"] }, 100]}
            }},
        lowGrowthRate: {
            $cond: {
                if: { $eq: ["$prevLow", 0] }, then: 0,
                    else: { $multiply: [{ $divide: [{ $subtract: ["$avgLow2024", "$prevLow"] }, "$prevLow"] }, 100]}
            }}
    }}
])

// 6.	[customer_booking] For each sales_channel and each route, display the following ratios
// -	average length_of_stay / average flight_hour 
// -	average wants_extra_baggage / average flight_hour
// -	average wants_preferred_seat / average flight_hour
// -	average wants_in_flight_meals / average flight_hour

// Our underlying objective: Are there any correlations between flight hours, length of stay, and various preferences (i.e., extra baggage, preferred seats, in-flight meals)?


use "customer_booking"
db.customer_booking.find()

db.customer_booking.aggregate([
    {$group:{
        _id:{
            sales_channel:"$sales_channel",
            route:"$route"},
        avg_length_of_stay: { $avg: { $toDouble: "$length_of_stay" }},
        avg_flight_hour: { $avg: { $toDouble: "$flight_hour" }},
        avg_wants_extra_baggage: { $avg: { $toDouble: "$wants_extra_baggage" }},
        avg_wants_preferred_seat: { $avg: { $toDouble: "$wants_preferred_seat" }},
        avg_wants_in_flight_meals: { $avg: { $toDouble: "$wants_in_flight_meals" }}
    }},
    {$project:{
        ratio_length_of_stay: { $cond: {if: {$eq: ["$avg_flight_hour",0]}, then:null, else: {$divide: ["$avg_length_of_stay", "$avg_flight_hour"] }}},
        ratio_wants_extra_baggage: { $cond: {if: {$eq: ["$avg_flight_hour",0]}, then:null, else: {$divide: ["$avg_wants_extra_baggage", "$avg_flight_hour"] }}},
        ratio_wants_preferred_seat: { $cond: {if: {$eq: ["$avg_flight_hour",0]}, then:null, else: {$divide: ["$avg_wants_preferred_seat", "$avg_flight_hour"] }}},
        ratio_wants_in_flight_meals: { $cond: {if: {$eq: ["$avg_flight_hour",0]}, then:null, else: {$divide: ["$avg_wants_in_flight_meals", "$avg_flight_hour"] }}}
    }}
    ])










