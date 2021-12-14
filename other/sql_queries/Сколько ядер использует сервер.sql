SELECT * FROM sys.dm_os_schedulers WHERE status = 'VISIBLE ONLINE' AND is_online = 1;
GO
EXEC sys.xp_readerrorlog 0, 1, N'detected', N'socket';