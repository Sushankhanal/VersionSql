/****** Object:  Procedure [dbo].[api_SaveOrderDetail_xml]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================C1SO00000005
-- exec api_SaveOrderDetail 'comp02','Tablet01','Tablet01','R8','C1SO00000005','P0022','half',1,0
-- exec api_SaveOrderDetail 'Tablet01','comp02','','TB01','COR00000095','P0022-0','full',1,0
CREATE PROCEDURE [dbo].[api_SaveOrderDetail_xml]
	-- Add the parameters for the stored procedure here
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@strUserCode	nvarchar(50),
	@strTableCode	nvarchar(50),
	@strOrderNo		nvarchar(50),
	@strDetail		XML,
	--@strItemCode	nvarchar(50),
	--@strUOM			nvarchar(50), -- half or full
	--@intQty			int,
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


	DECLARE @objXml XML, @intDoc INT
	SELECT @objXml = @strDetail
	--print convert(nvarchar(max),@objXml)
	EXEC sp_xml_preparedocument @intDoc OUTPUT, @objXml
	--print @intDoc

	DECLARE @tblTemp TABLE
	(intRunNo int, strItemCode nvarchar(50), strUOM nvarchar(50), intQty int, ISPROCCESS int)
	
	INSERT INTO @tblTemp
	(intRunNo, strItemCode, strUOM, intQty, ISPROCCESS)
	SELECT intRunNo, strItemCode, strUOM, intQty, 0
	FROM OPENXML (@intDoc,  N'/NewDataSet/Table1', 2)
	WITH (intRunNo int, strItemCode nvarchar(50), strUOM nvarchar(50), intQty int)


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

	if (select COUNT(Payment_ID) from tblPayment_Order where Payment_ReceiptNo = @strOrderNo) = 0
	BEGIN
		set @intErrorCode = -6
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Order number not exist.'
		RAISERROR (@strErrorText,16,1);  
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		Select @intErrorCode as ResultCode, @strErrorText as ResultText
		RETURN (@intErrorCode)
	END

	if (select COUNT(Payment_ID) from tblPayment_Order where Payment_ReceiptNo = @strOrderNo and Payment_TableCode = @strTableCode) = 0
	BEGIN
		set @intErrorCode = -7
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Table code not belong to this order number.'
		RAISERROR (@strErrorText,16,1);  
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		Select @intErrorCode as ResultCode, @strErrorText as ResultText
		RETURN (@intErrorCode)
	END

	if (select COUNT(Payment_ID) from tblPayment_Order  where Payment_CompanyCode = @strCompanyCode and Payment_Status = 0 AND Payment_TableCode = @strTableCode) > 1
	BEGIN
		set @intErrorCode = -5
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Multiple order number exist, please contact administrator.'
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
		
		DECLARE @IS_PROCCESS AS INT = 0
		DECLARE @strItemCode nvarchar(100) = ''
		DECLARE @strUOM nvarchar(50) = ''
		DECLARE @intQty int = 0
		DECLARE @intRunNo int = 0

		

		SET @IS_PROCCESS = 0
		WHILE @IS_PROCCESS = 0 
		BEGIN
			SELECT TOP 1 @intRunNo = intRunNo, @strItemCode = strItemCode, @strUOM = strUOM, @intQty = intQty
			FROM @tblTemp WHERE ISPROCCESS = 0 
			IF @@ROWCOUNT = 0
				BEGIN
					SET @IS_PROCCESS = 1
				END
			ELSE
				BEGIN
					if @intRunNo = 1
					BEGIN
						Declare @intItemGroup int = 0
						select @intItemGroup = pc.ProCategory_Group from tblProduct P 
						inner join tblProductCategory pc on pc.ProCategory_Code = P.Product_CategoryCode where Product_ItemCode = @strItemCode

						if @intItemGroup = 1
						BEGIN
							If (Select COUNT(PaymentD_ID) from tblPayment_Details (NOLOCK) where PaymentD_ReceiptNo = @strOrderNo 
							AND PaymentD_ItemCode = 'HOTPOT') = 0
							BEGIN
								Declare @intHotpotID int = 0
								DECLARE @strPrinterNameHotpot nvarchar(50) = ''
								select @strPrinterNameHotpot = Product_PrinterName from tblProduct  (NOLOCK) where Product_ItemCode = 'HOTPOT'
							
								INSERT INTO tblPayment_Details
								(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
								PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TransDate, PaymentD_Qty, 
								PaymentD_CreatedDate, PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, 
								PaymentD_RunNo, PaymentD_DiscountMode, PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName,
								PaymentD_DeviceCode)
								select @strOrderNo,'HOTPOT','full', Product_UnitPrice,0,
								0,Product_UnitPrice, GETDATE(), 1,
								GETDATE(), 0,'',6, 0,
								1,0,Product_Desc, Product_ChiDesc, @strPrinterNameHotpot,
								@strDeviceCode   from tblProduct 
								where Product_ItemCode = 'HOTPOT'
								select @intHotpotID = @@IDENTITY

								INSERT INTO tblPayment_Details_Print
								(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
								PaymentD_RunNo, PaymentD_Status, PaymentD_PrintStatus, PaymentD_Detail_ID, 
								PaymentD_CompanyCode,
								PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName)
								select PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM,
								 PaymentD_TransDate, @intQty, GETDATE(), 
								PaymentD_RunNo, 'new',0, @intHotpotID, @strCompanyCode,
								PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName 
								from tblPayment_Details  (NOLOCK) where PaymentD_ID = @intHotpotID

							END
						END

						
					END


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

					--print @strPrinterName
						if @intPayDetailID = 0
						BEGIN
							Declare @intCountD int = 0
							select top 1 @intCountD = PaymentD_RunNo from tblPayment_Details (NOLOCK) where PaymentD_ReceiptNo = @strOrderNo 
							Order by PaymentD_RunNo desc

							set @intCountD = @intCountD + 1

							INSERT INTO tblPayment_Details
							(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
							PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TransDate, PaymentD_Qty, 
							PaymentD_CreatedDate, PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, 
							PaymentD_RunNo, PaymentD_DiscountMode, PaymentD_ItemName, PaymentD_ItemNameChi, 
							PaymentD_PrinterName, PaymentD_DeviceCode)
							VALUES (
							@strOrderNo,@strItemCode,@strUOM,@dblUnitPrice,0,
							0,(@intQty * @dblUnitPrice),GETDATE(),@intQty,
							GETDATE(),@dblUnitCost,@strTaxCode,@dblTaxRate, ((@intQty * @dblUnitPrice) * (@dblTaxRate/100)),
							@intCountD,0,@strItemName,@strItemNameChi, @strPrinterName, @strDeviceCode)
			
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

							Update tblPayment_Details set PaymentD_DeviceCode = @strDeviceCode
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

							Declare @dblTotalAmtOrder money = 0
							select @dblTotalAmtOrder = (PaymentD_NetAmount) from tblPayment_Details (NOLOCK) where PaymentD_ReceiptNo = @strOrderNo
							-- need cal tax in future
							Update tblPayment_Order set Payment_GrossAmt = @dblTotalAmtOrder, Payment_NetAmt = @dblTotalAmtOrder, Payment_FinalAmt = @dblTotalAmtOrder
							where Payment_ReceiptNo = @strOrderNo

							
						END

					Update @tblTemp set ISPROCCESS = 1 WHERE intRunNo = @intRunNo
				END
	
				
		END
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

	

	--select * from @tblTemp

	select @intDetailID
	

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
