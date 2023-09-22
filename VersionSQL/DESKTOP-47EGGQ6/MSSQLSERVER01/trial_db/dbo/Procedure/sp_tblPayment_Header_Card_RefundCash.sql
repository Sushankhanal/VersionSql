/****** Object:  Procedure [dbo].[sp_tblPayment_Header_Card_RefundCash]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Header_Card_Add 'user001','','COUNTER1','Hallaway01',10,0,0,0,10,'',xml,'','',2,'',6,'','','',0
CREATE PROCEDURE [dbo].[sp_tblPayment_Header_Card_RefundCash]
-- Add the parameters for the stored procedure here
--@intID			nvarchar(50) OUT,
@strPOSUserCode        NVARCHAR(50), 
@strCounterCode        NVARCHAR(50), 
@strCompanyCode        NVARCHAR(50), 
@dblRefundAmount       MONEY, 
@strRemarks            NVARCHAR(MAX), 
@strCardNumber         NVARCHAR(50), 
@intPaymentType        INT, 
@strPaymentTypeRemarks NVARCHAR(50), 
@intIsRefundDeposit    INT, 
@strReceiptNo          NVARCHAR(50) OUT, 
@strClientFullName     NVARCHAR(50) OUT, 
@strClientBalance      MONEY OUT, 
@strClientPoint        DECIMAL(38, 10) OUT

AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_sp_tblPayment_Header_Card_RefundCash]
		@strPOSUserCode,
@strCounterCode,
@strCompanyCode,
@dblRefundAmount,
@strRemarks,
@strCardNumber,
@intPaymentType,
@strPaymentTypeRemarks,
@intIsRefundDeposit,
@strReceiptNo OUT,
@strClientFullName OUT,
@strClientBalance OUT,
@strClientPoint OUT,
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
	 EXEC[dbo].[Local_sp_tblPayment_Header_Card_RefundCash]
	@strPOSUserCode,
@strCounterCode,
@strCompanyCode,
@dblRefundAmount,
@strRemarks,
@strCardNumber,
@intPaymentType,
@strPaymentTypeRemarks,
@intIsRefundDeposit,
@strReceiptNo OUT,
@strClientFullName OUT,
@strClientBalance OUT,
@strClientPoint OUT

    end

END
