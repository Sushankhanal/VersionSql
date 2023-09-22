/****** Object:  Procedure [dbo].[sp_tblPayment_Refund_Card]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Refund_Card '9090','9090','aaa','Hallaway01','C18RE00000800','1050211017','','',0

CREATE PROCEDURE [dbo].[sp_tblPayment_Refund_Card]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strClientUserCode		nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@strReceiptNo		nvarchar(50),
	@strCardNumber		nvarchar(50),
	@strNewReceiptNo		nvarchar(50) OUT,
	@strClientFullName	nvarchar(50) OUT,
	@strClientBalance	money OUT

	AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_sp_tblPayment_Refund_Card]
		@strPOSUserCode,
@strClientUserCode,
@strCounterCode,
@strCompanyCode,
@strReceiptNo,
@strCardNumber,
@strNewReceiptNo OUT,
@strClientFullName OUT,
@strClientBalance OUT,
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
	 EXEC[dbo].[Local_sp_tblPayment_Refund_Card]
		@strPOSUserCode,
@strClientUserCode,
@strCounterCode,
@strCompanyCode,
@strReceiptNo,
@strCardNumber,
@strNewReceiptNo OUT,
@strClientFullName OUT,
@strClientBalance OUT

    end

END
