/****** Object:  Procedure [dbo].[api_RemoveOrderDetail]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================C1SO00000005
-- exec api_SaveOrderDetail 'comp02','Tablet01','Tablet01','R8','C1SO00000005','P0022','half',1,0
-- exec api_SaveOrderDetail 'comp02','Tablet01','Tablet01','R8','C1SO00000005','P0022','full',1,0
CREATE PROCEDURE [dbo].[api_RemoveOrderDetail]
	-- Add the parameters for the stored procedure here
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@strTableCode	nvarchar(50),
	@strOrderNo		nvarchar(50),
	@intDetailID	bigint
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @strErrorText nvarchar(255) = ''
	Declare @intErrorCode int = 0

	Declare @intBranchID int = 0
	select top 1 @intBranchID = Branch_ID from tblBranch where Branch_CompanyCode = @strCompanyCode
	
	if @strOrderNo = ''
	BEGIN
		set @intErrorCode = -2
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Order number not exist.'
		RAISERROR (@strErrorText,16,1);  
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		RETURN (@intErrorCode)
	END

    Declare @intTableStatus int = -1
	Select @intTableStatus = Table_Status from tblTable where Table_Code = @strTableCode
	AND Table_CompanyCode= @strCompanyCode

	if @intTableStatus = 1
	BEGIN

		Declare @intPayDetailID	bigint = 0
		select @intPayDetailID = PaymentD_ID from tblPayment_Details D
		where PaymentD_ReceiptNo = @strOrderNo AND PaymentD_ID = @intDetailID

		if @intPayDetailID = 0
		BEGIN
			set @intErrorCode = -3
			set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
			' - Detail not exist.'
			RAISERROR (@strErrorText,16,1);  
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (@intErrorCode)
		END

		if @intPayDetailID <> 0
		BEGIN
			Declare @intPrintID bigint = 0
			INSERT INTO tblPayment_Details_Print
			(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
			PaymentD_RunNo, PaymentD_Status, PaymentD_PrintStatus, PaymentD_Detail_ID, PaymentD_CompanyCode)
			select PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, GETDATE(), PaymentD_Qty, GETDATE(), 
			0, 'delete',0, PaymentD_ID, @strCompanyCode from tblPayment_Details where PaymentD_ID = @intDetailID
			select @intPrintID = @@IDENTITY

			update tblPayment_Details_Print 
			set 
			PaymentD_ItemName = (CASE d.PaymentD_UOM WHEN 'half' THEN P.Product_Desc2 ELSE P.Product_Desc END), 
			PaymentD_ItemNameChi = (CASE d.PaymentD_UOM WHEN 'half' THEN P.Product_ChiDesc2 ELSE P.Product_ChiDesc END),
			PaymentD_PrinterName = 'Foxit Reader PDF Printer' --P.Product_PrinterName
			from tblPayment_Details_Print d
			inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
			where PaymentD_ID = @intPrintID

			Declare @strCompanyMasterPrinter nvarchar(50) = ''
			Select @strCompanyMasterPrinter = Company_MasterPrinter from tblCompany where Company_Code = @strCompanyCode


			if @strCompanyMasterPrinter <> ''
			BEGIN
				INSERT INTO tblPayment_Details_Print
				(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
				PaymentD_RunNo, PaymentD_Status, PaymentD_PrintStatus, PaymentD_Detail_ID, PaymentD_CompanyCode)
				select PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, GETDATE(), PaymentD_Qty, GETDATE(), 
				0, 'delete',0, PaymentD_ID, @strCompanyCode from tblPayment_Details where PaymentD_ID = @intDetailID
				select @intPrintID = @@IDENTITY

				update tblPayment_Details_Print set 
				PaymentD_ItemName = (CASE d.PaymentD_UOM WHEN 'half' THEN '*' + P.Product_Desc2 ELSE '*' + P.Product_Desc END), 
				PaymentD_ItemNameChi = (CASE d.PaymentD_UOM WHEN 'half' THEN '*' + P.Product_ChiDesc2 ELSE P.Product_ChiDesc END),
				PaymentD_PrinterName = @strCompanyMasterPrinter
				from tblPayment_Details_Print d
				inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
				where PaymentD_ID = @intPrintID

			END

			Delete from tblPayment_Details where PaymentD_ID = @intDetailID

		END
		
	
	END
	ELSE
	BEGIN
		set @intErrorCode = -2
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Table still in vacant status.'
		RAISERROR (@strErrorText,16,1);  
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		RETURN (@intErrorCode)
	END

	Select 0 as result

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
