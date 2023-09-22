/****** Object:  Procedure [dbo].[Wapi_tblCard_Update]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Wapi_tblCard_Update]
	@intID		int ,
	@strSerialNo	nvarchar(50),
	@intType	smallint,
	@intStatus	smallint,
	@strUsercode	nvarchar(50)
AS
BEGIN
	   DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value=	[dbo].[Cloud_Wapi_tblCard_Update]
	@intID,
	@strSerialNo,
	@intType,
	@intStatus,
	@strUsercode,
	@cardid output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_Wapi_tblCard_Update]
	@intID,
	@strSerialNo,
	@intType,
	@intStatus,
	@strUsercode

    end
END
