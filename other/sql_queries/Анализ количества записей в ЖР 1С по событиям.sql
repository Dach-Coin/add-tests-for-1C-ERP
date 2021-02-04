select
T1.count_event, T2.name
FROM (select eventCode as eventCode, count(rowID) as count_event from EventLog group by eventCode order by count_event desc) AS T1 
inner join eventCodes AS T2 ON T1.eventCode = T2.code;

select * from EventLog where eventCode = 39 limit 5