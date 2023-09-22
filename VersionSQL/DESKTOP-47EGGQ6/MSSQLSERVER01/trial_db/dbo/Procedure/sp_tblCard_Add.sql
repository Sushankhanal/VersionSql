/****** Object:  Procedure [dbo].[sp_tblCard_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCard_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
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

EXEC @return_value= [dbo].[Cloud_sp_tblCard_Add]
		@ID	,
	@strSerialNo,
	@intType,
	@intStatus,
	@strOwnerName,
	@strOwnerMobile,
	@intOwnerGender,
	@strUsercode	,
	@cardid output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;


    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_sp_tblCard_Add]
		@ID	,
	@strSerialNo,
	@intType,
	@intStatus,
	@strOwnerName,
	@strOwnerMobile,
	@intOwnerGender,
	@strUsercode	

    end

END
