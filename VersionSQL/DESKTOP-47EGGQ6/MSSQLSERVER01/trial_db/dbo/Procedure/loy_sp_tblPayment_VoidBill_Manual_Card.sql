/****** Object:  Procedure [dbo].[loy_sp_tblPayment_VoidBill_Manual_Card]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
--exec loy_sp_tblPayment_VoidBill_Manual_Card 'user1','user1','hallaway01','C1RE00000804','0010460954','','',0
CREATE PROCEDURE [dbo].[loy_sp_tblPayment_VoidBill_Manual_Card]
-- Add the parameters for the stored procedure here
--@intID			nvarchar(50) OUT,
@strPOSUserCode    NVARCHAR(50), 
@strClientUserCode NVARCHAR(50), 
@strCompanyCode    NVARCHAR(50), 
@strReceiptNo      NVARCHAR(50), 
@strCardNumber     NVARCHAR(50), 
@strNewReceiptNo   NVARCHAR(50) OUT, 
@strClientFullName NVARCHAR(50) OUT, 
@strClientBalance  MONEY OUT
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_loy_sp_tblPayment_VoidBill_Manual_Card]
		@strPOSUserCode,
		@strClientUserCode,
		@strCompanyCode,
		@strReceiptNo,
		@strCardNumber,
		@strNewReceiptNo,
		@strClientFullName,
		@strClientBalance,
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
	 EXEC[dbo].[Local_loy_sp_tblPayment_VoidBill_Manual_Card]
		@strPOSUserCode,
		@strClientUserCode,
		@strCompanyCode,
		@strReceiptNo,
		@strCardNumber,
		@strNewReceiptNo,
		@strClientFullName,
		@strClientBalance

  
  end
END
