/****** Object:  Procedure [dbo].[api_SaveOrderMaster]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec api_SaveOrderMaster 'Tablet01','comp02','1111','TB15','',2
CREATE PROCEDURE [dbo].[api_SaveOrderMaster]
	-- Add the parameters for the stored procedure here
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@strUserCode	nvarchar(50),
	@strTableCode	nvarchar(50),
	@strOrderNo		nvarchar(50) OUT,
	@intPax			int
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	set @strOrderNo = ''
	Declare @strErrorText nvarchar(255) = ''
	Declare @intErrorCode int = 0

	Declare @intBranchID int = 0
	select top 1 @intBranchID = Branch_ID from tblBranch where Branch_CompanyCode = @strCompanyCode
	
	--if @strUserCode <> ''
	--BEGIN
	--	if (select ISNULL(COUNT(POSUser_ID),0) from tblPOSUser where POSUser_CompanyCode = @strCompanyCode
	--	AND POSUser_Code = @strUserCode AND POSUser_Password = @strUserCode) = 0
	--	BEGIN
	--		set @intErrorCode = -1
	--		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
	--		' - Invalid Access Code.'
	--		RAISERROR (@strErrorText,16,1);  
	--		ROLLBACK TRANSACTION
	--		SET NOCOUNT OFF
	--		Select @intErrorCode as ResultCode, @strErrorText as ResultText
	--		RETURN (@intErrorCode)
	--	END
		
	--END

	if (select COUNT(Payment_ID) from tblPayment_Order  where Payment_CompanyCode = @strCompanyCode and Payment_Status = 0 AND Payment_TableCode = @strTableCode) <> 0
	BEGIN
		set @intErrorCode = -5
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Selected table still has Order number, Please contact administrator.'
		RAISERROR (@strErrorText,16,1);  
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		Select @intErrorCode as ResultCode, @strErrorText as ResultText
		RETURN (@intErrorCode)
	END

    Declare @intTableStatus int = -1
	Select @intTableStatus = Table_Status from tblTable where Table_Code = @strTableCode
	AND Table_CompanyCode= @strCompanyCode

	if @intTableStatus = 0
	BEGIN
		
		DECLARE @PrefixType VARCHAR(50) = ''
		DECLARE @intRowCount INT
		set @PrefixType = 'Receipt'
		EXEC sp_tblPrefixNumber_GetNextRunNumber 'Order', @PrefixType, @intBranchID, @strOrderNo OUTPUT
		if @strOrderNo = ''
		BEGIN
			set @intErrorCode = -2
			set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
			' - Fail to generate order number.'
			RAISERROR (@strErrorText,16,1);  
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			Select @intErrorCode as ResultCode, @strErrorText as ResultText
			RETURN (@intErrorCode)
		END

		Declare @strCounterPrefix nvarchar(50) = ''
		select @strCounterPrefix = Counter_ID from tblCounter where Counter_Code = @strDeviceCode
		set @strCounterPrefix = 'C' + @strCounterPrefix
		set @strOrderNo = @strCounterPrefix + @strOrderNo

		INSERT INTO tblPayment_Order
		(Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, 
		Payment_FinalAmt, Payment_CounterCode, Payment_Status, Payment_CreatedDate, 
		Payment_UserCode, Payment_TotalTaxAmt, Payment_CreatedBy, Payment_Remarks, Payment_CollectionCode, Payment_TableCode, Payment_Pax,
		Payment_CompanyCode)
		VALUES
		(@strOrderNo,GETDATE(),0,0,0,0,
		0,@strDeviceCode,0,GETDATE(),@strUserCode,0,@strUserCode,'','',@strTableCode, @intPax, @strCompanyCode)


		update  tblTable set Table_Status = 1 where Table_Code = @strTableCode
		AND Table_CompanyCode= @strCompanyCode


		--If (Select COUNT(PaymentD_ID) from tblPayment_Details (NOLOCK) where PaymentD_ReceiptNo = @strOrderNo 
		--AND PaymentD_ItemCode = 'HOTPOT') = 0
		--BEGIN
		--	INSERT INTO tblPayment_Details
		--	(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
		--	PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TransDate, PaymentD_Qty, 
		--	PaymentD_CreatedDate, PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, 
		--	PaymentD_RunNo, PaymentD_DiscountMode, PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName)
		--	select @strOrderNo,'HOTPOT','Unit', Product_UnitPrice,0,
		--	0,Product_UnitPrice, GETDATE(), 1,
		--	GETDATE(), 0,'',6, 0,
		--	0,0,Product_Desc, Product_ChiDesc, ''   from tblProduct 
		--	where Product_ItemCode = 'HOTPOT'
		--END

		set @intErrorCode = 0
		set @strErrorText = 'Success'
		Select @intErrorCode as ResultCode, @strErrorText as ResultText
	END
	ELSE
	BEGIN
		set @intErrorCode = -1
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Unable open new order to selected table due to selected table still in used.'
		RAISERROR (@strErrorText,16,1);  
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		Select @intErrorCode as ResultCode, @strErrorText as ResultText
		RETURN (@intErrorCode)
	END

	--select @strOrderNo

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
