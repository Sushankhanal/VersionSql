/****** Object:  Procedure [dbo].[sp_tblCardPointTrans_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
--exec sp_tblCardPointTrans_Add 0,0,'0010460954'5,300,'','',
CREATE PROCEDURE [dbo].[sp_tblCardPointTrans_Add]
	-- Add the parameters for the stored procedure here
	@ID			int OUT,
	@intPlayerID	bigint,
	@strSerialNo	nvarchar(50),
	@intTransType	smallint,
	@dblPointAmt	decimal(38, 10),
	@strRemarks		nvarchar(500),
	@strUsercode		nvarchar(50),
	@strUsername		nvarchar(50),
	@strPassword		nvarchar(50),
	@intPointType		int = 0

AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_sp_tblCardPointTrans_Add]
		@ID			 ,
	@intPlayerID	,
	@strSerialNo	,
	@intTransType	,
	@dblPointAmt	,
	@strRemarks	,
	@strUsercode	,
	@strUsername	,
	@strPassword		,
	@intPointType		,
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
	 EXEC[dbo].[Local_sp_tblCardPointTrans_Add]
			@ID			 ,
	@intPlayerID	,
	@strSerialNo	,
	@intTransType	,
	@dblPointAmt	,
	@strRemarks	,
	@strUsercode	,
	@strUsername	,
	@strPassword		,
	@intPointType		

    end

END
