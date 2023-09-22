/****** Object:  Procedure [dbo].[sp_tblCard_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
--exec sp_tblCard_Update 0,'00112233445566',1,0,'','',0,''
CREATE PROCEDURE [dbo].[sp_tblCard_Update]
	-- Add the parameters for the stored procedure here
	@ID		int ,
	@strSerialNo	nvarchar(50),
	@intType	smallint,
	@intStatus	smallint,
	@strOwnerName	nvarchar(50),
	@strOwnerMobile	nvarchar(50),
	@intOwnerGender	smallint,
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

EXEC @return_value= [dbo].[Local_sp_tblCard_Update]
		@ID,
	@strSerialNo,
	@intType,
	@intStatus,
	@strOwnerName,
	@strOwnerMobile,
	@intOwnerGender,
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
	 EXEC[dbo].[Local_sp_tblCard_Update]
	@ID,
	@strSerialNo,
	@intType,
	@intStatus,
	@strOwnerName,
	@strOwnerMobile,
	@intOwnerGender,
	@strUsercode
    end

END
