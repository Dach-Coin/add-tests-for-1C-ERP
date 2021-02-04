USE EDB_consolidation

DECLARE @tablename NVARCHAR(128)
DECLARE @querytext NVARCHAR(1500)
DECLARE @counter TINYINT
DECLARE @source NVARCHAR(50)
DECLARE @destination NVARCHAR(50)

SET @counter = 0

WHILE @counter <= 1
BEGIN
	
	IF @counter = 0
	BEGIN
		SET @source = 'op_[0-9][0-9_]_%'
		SET @destination = 'EdbTranzactions'
	END
	ELSE
	BEGIN
		SET @source = 'opPC_[0-9][0-9_]_%'
		SET @destination = 'EdbTranzactionsPC'
	END
		
	DECLARE tables CURSOR FOR
	  SELECT TABLE_NAME
	  FROM INFORMATION_SCHEMA.TABLES
	  WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME <> 'dtproperties' AND TABLE_NAME LIKE @source
  
	OPEN tables

	FETCH NEXT
	  FROM tables
	  INTO @tablename
  
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @querytext = '
		DECLARE @maxdate DATETIME
		
		SELECT @maxdate = MAX(datatran) FROM dbo.' + @tablename + '

		IF @maxdate IS NULL OR EOMONTH(@maxdate) >= EOMONTH(GETDATE())
			RETURN

		DECLARE @idbase INT
		DECLARE @guidedb NCHAR(36)

		DECLARE docsedb CURSOR FOR
			SELECT DISTINCT id_base1c, guid_doc_edb
			FROM dbo.' + @tablename + '
			WHERE id_base1c > 0 AND guid_doc_edb <> ''''

		OPEN docsedb

		BEGIN TRANSACTION

		FETCH NEXT
		  FROM docsedb
		  INTO @idbase, @guidedb 
	  
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DELETE FROM dbo.' + @destination +'
			WHERE id_base1c = @idbase AND guid_doc_edb = @guidedb

			INSERT INTO dbo.' + @destination + ' SELECT * FROM dbo.' + @tablename + '
			WHERE id_base1c = @idbase AND guid_doc_edb = @guidedb
		
			FETCH NEXT
			  FROM docsedb
			  INTO @idbase, @guidedb
		END

		DROP TABLE ' + @tablename + '
	
		COMMIT TRANSACTION 

		CLOSE docsedb
		DEALLOCATE docsedb'

		EXEC (@querytext)
	
		FETCH NEXT
		  FROM tables
		  INTO @tablename
	END

	CLOSE tables
	DEALLOCATE tables

	SET @counter = @counter + 1
END