/****** Object:  Procedure [dbo].[api_SaveOrderDetail]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================C1SO00000005
-- exec api_SaveOrderDetail 'comp02','Tablet01','Tablet01','R8','C1SO00000005','P0022','half',1,0
-- exec api_SaveOrderDetail 'Tablet01','comp02','','TB01','COR00000095','P0022-0','full',1,0
CREATE PROCEDURE [dbo].[api_SaveOrderDetail]
	-- Add the parameters for the stored procedure here
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@strUserCode	nvarchar(50),
	@strTableCode	nvarchar(50),
	@strOrderNo		nvarchar(50),
	@strItemCode	nvarchar(50),
	@strUOM			nvarchar(50), -- half or full
	@intQty			int,
	@intDetailID	int out
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @strErrorText nvarchar(255) = ''
	Declare @intErrorCode int = 0

	Declare @intBranchID int = 0
	select top 1 @intBranchID = Branch_ID from tblBranch (NOLOCK) where Branch_CompanyCode = @strCompanyCode
	
	Declare @strCompanyMasterPrinter nvarchar(50) = ''
	Select @strCompanyMasterPrinter = Company_MasterPrinter from tblCompany (NOLOCK) where Company_Code = @strCompanyCode


	--if @strUserCode <> ''
	--BEGIN
	--	if (select ISNULL(COUNT(POSUser_ID),0) from tblPOSUser (NOLOCK) where POSUser_CompanyCode = @strCompanyCode
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

	if @strOrderNo = ''
	BEGIN
		set @intErrorCode = -2
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Invalid order number.'
		RAISERROR (@strErrorText,16,1);  
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		Select @intErrorCode as ResultCode, @strErrorText as ResultText
		RETURN (@intErrorCode)
	END

    Declare @intTableStatus int = -1
	Select @intTableStatus = Table_Status from tblTable (NOLOCK) where Table_Code = @strTableCode
	AND Table_CompanyCode= @strCompanyCode


	if @intTableStatus = 1
	BEGIN
		
		Declare @dblUnitPrice money = 0
		Declare @dblUnitPrice2 money = 0
		Declare @dblUnitCost money = 0
		Declare @strTaxCode	nvarchar(50) = ''
		Declare @dblTaxRate money = 0

		select @dblUnitPrice = Product_UnitPrice, @dblUnitPrice2 = Product_UnitPrice2, @dblUnitCost = Product_Cost, 
		@strTaxCode = Product_TaxCode, @dblTaxRate = Product_TaxRate from tblProduct (NOLOCK) where Product_ItemCode = @strItemCode

		set @strUOM = LOWER(@strUOM)
		if @strUOM = 'half'
		BEGIN
			set @dblUnitPrice = @dblUnitPrice2
		END
		
		Declare @dblNetAmt money = 0
		Declare @dblTaxAmt money = 0
		Declare @intPayDetailID	bigint = 0

		select @intPayDetailID = PaymentD_ID from tblPayment_Details D (NOLOCK)
		where PaymentD_ReceiptNo = @strOrderNo AND PaymentD_ItemCode = @strItemCode
		AND PaymentD_UOM = @strUOM

		Declare @strItemName nvarchar(50) = ''
		Declare @strItemNameChi nvarchar(50) = ''
		Declare @strPrinterName nvarchar(50) = ''
		--select @strItemName = (CASE @strUOM WHEN 'half' THEN Product_Desc2 ELSE Product_Desc END) from tblProduct  (NOLOCK) where Product_ItemCode = @strItemCode
		--select @strItemNameChi = (CASE @strUOM WHEN 'half' THEN Product_ChiDesc2 ELSE Product_ChiDesc END) from tblProduct  (NOLOCK) where Product_ItemCode = @strItemCode
		select @strItemName = Product_Desc, @strItemNameChi = Product_ChiDesc from tblProduct  (NOLOCK) where Product_ItemCode = @strItemCode
		select @strPrinterName = Product_PrinterName from tblProduct  (NOLOCK) where Product_ItemCode = @strItemCode

		if @intPayDetailID = 0
		BEGIN
			Declare @intCountD int = 0
			select @intCountD = COUNT(PaymentD_ID) from tblPayment_Details (NOLOCK) where PaymentD_ReceiptNo = @strOrderNo 
			set @intCountD = @intCountD + 1

			
			INSERT INTO tblPayment_Details
			(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
			PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TransDate, PaymentD_Qty, 
			PaymentD_CreatedDate, PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, 
			PaymentD_RunNo, PaymentD_DiscountMode, PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName)
			VALUES (
			@strOrderNo,@strItemCode,@strUOM,@dblUnitPrice,0,
			0,(@intQty * @dblUnitPrice),GETDATE(),@intQty,
			GETDATE(),@dblUnitCost,@strTaxCode,@dblTaxRate, ((@intQty * @dblUnitPrice) * (@dblTaxRate/100)),
			@intCountD,0,@strItemName,@strItemNameChi, @strPrinterName)
			
			select @intDetailID = @@IDENTITY

			INSERT INTO tblPayment_Details_Print
			(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
			PaymentD_RunNo, PaymentD_Status, PaymentD_PrintStatus, PaymentD_Detail_ID, 
			PaymentD_CompanyCode,
			PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName)
			select PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM,
			 PaymentD_TransDate, @intQty, GETDATE(), 
			PaymentD_RunNo, 'new',0, @intDetailID, @strCompanyCode,
			PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName 
			from tblPayment_Details  (NOLOCK) where PaymentD_ID = @intDetailID

			

			if @strCompanyMasterPrinter <> ''
			BEGIN
				INSERT INTO tblPayment_Details_Print
				(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
				PaymentD_RunNo, PaymentD_Status, PaymentD_PrintStatus, PaymentD_Detail_ID, PaymentD_CompanyCode,
				PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName)
				select PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, @intQty, GETDATE(), 
				PaymentD_RunNo, 'new',0, @intDetailID, @strCompanyCode,
				'*' + PaymentD_ItemName, '*' + PaymentD_ItemNameChi, @strCompanyMasterPrinter 
				from tblPayment_Details  (NOLOCK) where PaymentD_ID = @intDetailID
			END

		END
		ELSE
		BEGIN
			Update tblPayment_Details set PaymentD_Qty = PaymentD_Qty + @intQty
			where PaymentD_ID = @intPayDetailID

			Update tblPayment_Details set PaymentD_NetAmount = (PaymentD_Qty * PaymentD_UnitPrice)
			where PaymentD_ID = @intPayDetailID
			Update tblPayment_Details set PaymentD_TaxAmt = (PaymentD_NetAmount * (PaymentD_TaxRate/100))
			where PaymentD_ID = @intPayDetailID

			set @intDetailID = @intPayDetailID

			
			INSERT INTO tblPayment_Details_Print
			(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
			PaymentD_RunNo, PaymentD_Status, PaymentD_PrintStatus, 
			PaymentD_Detail_ID, PaymentD_CompanyCode,
			PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName)
			select PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, 
			PaymentD_TransDate, @intQty, GETDATE(), 
			PaymentD_RunNo, 'new',0, @intDetailID, @strCompanyCode,
			PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName 
			from tblPayment_Details  (NOLOCK) where PaymentD_ID = @intDetailID

			if @strCompanyMasterPrinter <> ''
			BEGIN
				INSERT INTO tblPayment_Details_Print
				(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
				PaymentD_RunNo, PaymentD_Status, PaymentD_PrintStatus, PaymentD_Detail_ID, PaymentD_CompanyCode,
				PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName)
				select PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, @intQty, GETDATE(), 
				PaymentD_RunNo, 'new',0, @intDetailID, @strCompanyCode,
				'*' + PaymentD_ItemName, 
				'*' + PaymentD_ItemNameChi, @strCompanyMasterPrinter
				 from tblPayment_Details (NOLOCK) where PaymentD_ID = @intDetailID
			END

		END
		
		Declare @dblTotalAmtOrder money = 0
		select @dblTotalAmtOrder = (PaymentD_NetAmount) from tblPayment_Details (NOLOCK) where PaymentD_ReceiptNo = @strOrderNo
		-- need cal tax in future
		Update tblPayment_Order set Payment_GrossAmt = @dblTotalAmtOrder, Payment_NetAmt = @dblTotalAmtOrder, Payment_FinalAmt = @dblTotalAmtOrder
		where Payment_ReceiptNo = @strOrderNo

		set @intErrorCode = 0
		set @strErrorText = 'Success'
		Select @intErrorCode as ResultCode, @strErrorText as ResultText

	END
	ELSE
	BEGIN
		set @intErrorCode = -3
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Table still in vacant status.'
		RAISERROR (@strErrorText,16,1);  
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		Select @intErrorCode as ResultCode, @strErrorText as ResultText
		RETURN (@intErrorCode)
	END

	update tblPayment_Details
	set 
	PaymentD_ItemName = Product_Desc, 
	PaymentD_ItemNameChi = Product_ChiDesc,
	PaymentD_PrinterName = P.Product_PrinterName
	from tblPayment_Details d  (NOLOCK)
	inner join tblProduct P  (NOLOCK) on d.PaymentD_ItemCode = P.Product_ItemCode
	where d.PaymentD_ReceiptNo = @strOrderNo AND d.PaymentD_ItemName = ''


	select @intDetailID

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
