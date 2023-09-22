/****** Object:  Procedure [dbo].[Wapi_tblCardPointTrans_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
--exec sp_tblCardPointTrans_Add 0,0,'0010460954'5,300,'','',
CREATE PROCEDURE [dbo].[Wapi_tblCardPointTrans_Add]
	-- Add the parameters for the stored procedure here
	@intPlayerID	bigint,
	@strSerialNo	nvarchar(50),
	@intTransType	smallint,
	@dblPointAmt	decimal(38, 10),
	@strRemarks		nvarchar(500),
	@strUsername		nvarchar(50),
	@strPassword		nvarchar(50),
	@intPointType		int = 0,
	@intalterdBy		bigint
AS
 BEGIN
	   DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
	declare
	@return_value int,  
	@CardOwnerId        bigint,
	@CardId             bigint
EXEC	@return_value=	[dbo].[Local_Wapi_tblCardPointTrans_Add]
	@intPlayerID,
	@strSerialNo,
	@intTransType,
	@dblPointAmt,
	@strRemarks	,
	@strUsername,
	@strPassword,
	@intPointType,
	@intalterdBy,
	@CardOwnerId output,
    @CardId output;

	EXEC[dbo].[Sync_CardOwnerInsertUpdate] @CardOwnerId = @CardOwnerId;
EXEC [dbo].[Sync_CardInsertUpdate] @CardId = @CardId;

    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_Wapi_tblCardPointTrans_Add]
@intPlayerID,
	@strSerialNo,
	@intTransType,
	@dblPointAmt,
	@strRemarks	,
	@strUsername,
	@strPassword,
	@intPointType,
	@intalterdBy
    end
END
