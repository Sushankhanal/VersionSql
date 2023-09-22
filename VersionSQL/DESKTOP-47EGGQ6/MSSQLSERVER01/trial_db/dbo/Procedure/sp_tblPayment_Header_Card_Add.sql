/****** Object:  Procedure [dbo].[sp_tblPayment_Header_Card_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Header_Card_Add 'user001','','COUNTER1','Hallaway01',10,0,0,0,10,'',xml,'','',2,'',6,'','','',0
CREATE PROCEDURE [dbo].[sp_tblPayment_Header_Card_Add]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strClientUserCode	nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@dblGrossAmt		money,
	@dblGlobalDiscountRate	money,
	@dblRoundUp			money,
	@dblTaxAmt			money,
	@dblNetAmount		money,
	@strRemarks			nvarchar(max),
	@PaymentDetailXml	XML,
	@strCardNumber		nvarchar(50),
	@intPaymentType		int,
	@strPaymentTypeRemarks	nvarchar(50),
	@strReceiptNo		nvarchar(50) OUT,
	@strClientFullName	nvarchar(50) OUT,
	@strClientBalance	money OUT,
	@PaymentDetailAddOnXml	XML,
	@RedeemPoint		decimal(38, 10),
	@RedeemAmt			money,
	@strClientPoint		decimal(38, 10) OUT,
	@intDiscountMode	smallint,
	@strCollectCode		nvarchar(50),
	@dblCollectedAmt	money,
	@dblGlobalDiscountAmt	money,
	@strTableCode			nvarchar(50),
	@strOrderNumber			nvarchar(50),
	@PaymentDetailModeXml	XML = '',
	@intPax					int = 0
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_sp_tblPayment_Header_Card_Add]
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
@strCardNumber,
@intPaymentType,
@strPaymentTypeRemarks,
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
@PaymentDetailModeXml,
@intPax,

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
	 EXEC[dbo].[Local_sp_tblPayment_Header_Card_Add]
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
@strCardNumber,
@intPaymentType,
@strPaymentTypeRemarks,
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
