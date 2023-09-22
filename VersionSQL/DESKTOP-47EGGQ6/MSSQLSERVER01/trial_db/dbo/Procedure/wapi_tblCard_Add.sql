﻿/****** Object:  Procedure [dbo].[wapi_tblCard_Add]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[wapi_tblCard_Add]
@strSerialNo	nvarchar(50),
	@intType	smallint,
	@intStatus	smallint,
	@strUsercode	nvarchar(50)
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_wapi_tblCard_Add]
		@strSerialNo,
		@intType,
		@intStatus,
		@strUsercode,
		@cardid output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;


    
   END TRY
   BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
    PRINT @ErrorMessage
END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_wapi_tblCard_Add]
		@strSerialNo,
		@intType,
		@intStatus,
		@strUsercode

    end

END
