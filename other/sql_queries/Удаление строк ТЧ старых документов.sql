DELETE FROM [MSK_SHORT].[dbo].[_Document232_VT3609]
 WHERE [_Document232_IDRRef] IN
(SELECT DISTINCT [_Document232_IDRRef]
FROM [MSK_SHORT].[dbo].[_Document232_VT3609]
INNER JOIN
[MSK_SHORT].[dbo].[_Document232] AS T2
ON [MSK_SHORT].[dbo].[_Document232_VT3609].[_Document232_IDRRef] = T2.[_IDRRef] AND T2.[_Date_Time] < '4019-04-01 00:00:00')