/****** Object:  Procedure [dbo].[sp_tblPayment_Header_Add_Multiplay]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Header_Add_Multiplay 'user001','','COUNTER-01','Hallaway01',10,0,0,0,10,'',xml,'','',2,'xml',0,0,0,0,'',0,0,'','',xml
--,'','',0
CREATE PROCEDURE [dbo].[sp_tblPayment_Header_Add_Multiplay]
-- Add the parameters for the stored procedure here
--@intID			nvarchar(50) OUT,
@strPOSUserCode        NVARCHAR(50), 
@strClientUserCode     NVARCHAR(50), 
@strCounterCode        NVARCHAR(50), 
@strCompanyCode        NVARCHAR(50), 
@dblGrossAmt           MONEY, 
@dblGlobalDiscountRate MONEY, 
@dblRoundUp            MONEY, 
@dblTaxAmt             MONEY, 
@dblNetAmount          MONEY, 
@strRemarks            NVARCHAR(MAX), 
@PaymentDetailXml      XML, 
@strReceiptNo          NVARCHAR(50) OUT, 
@strClientFullName     NVARCHAR(50) OUT, 
@strClientBalance      MONEY OUT, 
@PaymentDetailAddOnXml XML, 
@RedeemPoint           DECIMAL(38, 10), 
@RedeemAmt             MONEY, 
@strClientPoint        DECIMAL(38, 10) OUT, 
@intDiscountMode       SMALLINT, 
@strCollectCode        NVARCHAR(50), 
@dblCollectedAmt       MONEY, 
@dblGlobalDiscountAmt  MONEY, 
@strTableCode          NVARCHAR(50), 
@strOrderNumber        NVARCHAR(50), 
@PaymentDetailModeXml  XML             = '', 
@intPax                INT             = 0
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_sp_tblPayment_Header_Add_Multiplay]
@strPOSUserCode,
@strClientUserCode,
@strCounterCode,
@strCompanyCode,
@dblGrossAmt,
@dblGlobalDiscountRate,
@dblRoundUp,
@dblTaxAmt,
@dblNetAmount,
@strRemarks,
@PaymentDetailXml,
@strReceiptNo ,
@strClientFullName ,
@strClientBalance ,
@PaymentDetailAddOnXml,
@RedeemPoint,
@RedeemAmt,
@strClientPoint ,
@intDiscountMode,
@strCollectCode,
@dblCollectedAmt,
@dblGlobalDiscountAmt,
@strTableCode,
@strOrderNumber,
@PaymentDetailModeXml ,
@intPax,
@cardid  output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;


    
   END TRY
   BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
    PRINT @ErrorMessage
END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_sp_tblPayment_Header_Add_Multiplay]
		@strPOSUserCode,
@strClientUserCode,
@strCounterCode,
@strCompanyCode,
@dblGrossAmt,
@dblGlobalDiscountRate,
@dblRoundUp,
@dblTaxAmt,
@dblNetAmount,
@strRemarks,
@PaymentDetailXml,
@strReceiptNo OUT,
@strClientFullName OUT,
@strClientBalance OUT,
@PaymentDetailAddOnXml,
@RedeemPoint,
@RedeemAmt,
@strClientPoint OUT,
@intDiscountMode,
@strCollectCode,
@dblCollectedAmt,
@dblGlobalDiscountAmt,
@strTableCode,
@strOrderNumber,
@PaymentDetailModeXml = '',
@intPax = 0


    end

END
