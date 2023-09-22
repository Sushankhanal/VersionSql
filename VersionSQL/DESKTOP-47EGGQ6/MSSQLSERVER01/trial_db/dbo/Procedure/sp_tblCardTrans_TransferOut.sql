/****** Object:  Procedure [dbo].[sp_tblCardTrans_TransferOut]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblCardTrans_TransferOut '1234567890','60124536362'
-- sp_tblCardTrans_TransferOut(CardSerialNo,MobileUserCode)
CREATE PROCEDURE [dbo].[sp_tblCardTrans_TransferOut]
-- Add the parameters for the stored procedure here
@strCardSerialNumber NVARCHAR(50), 
@strMobileUserCode   NVARCHAR(50)
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_sp_tblCardTrans_TransferOut]
		@strCardSerialNumber,
		@strMobileUserCode,
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
	 EXEC[dbo].[Local_sp_tblCardTrans_TransferOut]
		@strCardSerialNumber,
		@strMobileUserCode
		

    end

END
