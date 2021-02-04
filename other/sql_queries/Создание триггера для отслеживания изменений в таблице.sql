USE [ERP_demo]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- 1. Создаем таблицу для хранения отслеживаемых событий

CREATE TABLE [dbo].[_1C_Tracking_Changes](
	[UserName] [nchar](100) NULL,
	[ChangeDate] [datetime2](7) NULL,
	[SysPID] [numeric](5, 0) NULL,
	[TableName] [nchar](200) NULL,
	[OperationType] [nchar](1) NULL
) ON [PRIMARY]
GO

-- 2. Создаем триггер на операции Insert, Delete, Update на целевую таблицу

CREATE TRIGGER [dbo].[Del_Ins_Upd_Tracking]
ON [ERP_demo].[dbo].[_InfoRg122600]
AFTER DELETE, INSERT, UPDATE
AS 
BEGIN	
	
	SET NOCOUNT ON

	declare @ot nchar(1)

	if (exists(select * from inserted) and exists(select * from deleted)) 
		set @ot = 'U'
	if (not exists(select * from inserted) and exists(select * from deleted)) 
		set @ot = 'D'
	if (exists(select * from inserted) and not exists(select * from deleted)) 
		set @ot = 'I' 

	INSERT INTO dbo._1C_Tracking_Changes
	SELECT
		Suser_Sname() AS UserName
		,Getdate() AS ChangeDate
		,@@SPID AS SysPID
		,'InfoRg122600 - РеестрДокументов' AS TableName
		,@ot AS OperationType

END
GO

ALTER TABLE [dbo].[_InfoRg122600] ENABLE TRIGGER [Del_Ins_Upd_Tracking]
GO
