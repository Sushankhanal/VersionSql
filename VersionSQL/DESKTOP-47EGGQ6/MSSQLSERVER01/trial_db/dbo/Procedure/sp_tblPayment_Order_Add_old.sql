﻿/****** Object:  Procedure [dbo].[sp_tblPayment_Order_Add_old]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[sp_tblPayment_Order_Add_old]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@dblGrossAmt		money,
	@dblRoundUp			money,
	@dblTaxAmt			money,
	@dblNetAmount		money,
	@strRemarks			nvarchar(max),
	@PaymentDetailXml	XML,
	@strReceiptNo		nvarchar(50) OUT,
	@PaymentDetailAddOnXml	XML,
	@strCollectCode		nvarchar(50),
	@strTableCode		nvarchar(50),
	@strOrderNumber		nvarchar(50) = '',
	@intDiscountMode	smallint,
	@dblGlobalDiscountRate	money,
	@dblGlobalDiscountAmt	money
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @dblCompanySST money = 0
	Declare @dblCompanySC money = 0
	Select @dblCompanySST = Company_SST, @dblCompanySC = Company_SC from tblCompany where Company_Code = @strCompanyCode
	set @dblCompanySST = (@dblCompanySST / 100)
	set @dblCompanySC = (@dblCompanySC / 100)

	if @dblCompanySST = 0 and @dblCompanySC = 0
	BEGIN
		Select @dblCompanySST = Counter_SST, @dblCompanySC = Counter_SC from tblCounter where Counter_Code = @strCounterCode
		AND Counter_CompanyCode = @strCompanyCode
	END

	--- Check Item got mix the product sign or not
		DECLARE @objXml XML, @intDoc INT
		SELECT @objXml = @PaymentDetailXml
		EXEC sp_xml_preparedocument @intDoc OUTPUT, @objXml
		--print @intDoc

		DECLARE @tblTemp TABLE
		(ID int, itemCode nvarchar(50), UOM nvarchar(50), UnitPrice money, Qty int, ItemDiscountAmt money, ItemDiscountPercentage float, 
		ItemTaxCode nvarchar(50), ItemTaxRate money, ItemTaxAmt money, NetAmount money, DiscountMode int, UnitCost money, ItemSign smallint, 
		WalletTransType int, ISPROCCESS int)
	
		INSERT INTO @tblTemp
		(ID, itemCode, UOM, UnitPrice, Qty, ItemDiscountAmt, ItemDiscountPercentage, 
		ItemTaxCode, ItemTaxRate, ItemTaxAmt, NetAmount,DiscountMode,UnitCost,ItemSign, WalletTransType, ISPROCCESS)
		SELECT DetailID, itemCode, UOM, UnitPrice, Qty, ItemDiscountAmt, ItemDiscountPercentage, 
		ItemTaxCode, ItemTaxRate, ItemTaxAmt, NetAmount,DiscountMode, 0, 0, 0, 0
		FROM OPENXML (@intDoc,  N'/NewDataSet/Table1', 2)
		WITH (DetailID int, itemCode nvarchar(50), UOM nvarchar(50), UnitPrice money, Qty int, ItemDiscountAmt money, ItemDiscountPercentage float, 
		ItemTaxCode nvarchar(50), ItemTaxRate money, ItemTaxAmt money, NetAmount money, DiscountMode int)

		Update @tblTemp set ItemSign = WT.WTransType_Sign, WalletTransType = P.Product_WalletsTransType
		From @tblTemp t inner join tblProduct P on t.itemCode = P.Product_ItemCode
		inner join tblWalletTransType WT on P.Product_WalletsTransType = WT.WTransType_ID

		select @@ROWCOUNT from @tblTemp Group by ItemSign

		DECLARE @IS_PROCCESS AS INT

		if @strOrderNumber = '0' BEGIN set @strOrderNumber = '' END

		if @strOrderNumber = ''
		BEGIN
			DECLARE @PrefixType VARCHAR(50), @intRowCount INT
			--Declare @strReceiptNo nvarchar(50)
			set @PrefixType = 'Receipt'
			EXEC sp_tblPrefixNumber_GetNextRunNumber 'Order', @PrefixType, 0, @strReceiptNo OUTPUT
			Declare @strCounterPrefix nvarchar(50) = ''
			select @strCounterPrefix = Counter_ID from tblCounter where Counter_Code = @strCounterCode
			set @strCounterPrefix = 'C' + @strCounterPrefix
			set @strReceiptNo = @strCounterPrefix + @strReceiptNo
			print @strReceiptNo

			INSERT INTO tblPayment_Order
			(Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, Payment_FinalAmt, 
			Payment_CounterCode, 
			Payment_Status, Payment_CreatedDate, 
			Payment_UserCode, Payment_TotalTaxAmt, Payment_CreatedBy, Payment_Remarks,
			Payment_CollectionCode, Payment_TableCode, Payment_CompanyCode, Payment_DiscountMode,Payment_GlobalDiscount, 
			Payment_GlobalDiscountAmt, Payment_SST)
			VALUES (
			@strReceiptNo,GETDATE(),@dblGrossAmt,0,@dblNetAmount,@dblRoundUp,@dblNetAmount,
			@strCounterCode,
			0,GETDATE(),
			@strPOSUserCode,@dblTaxAmt, @strPOSUserCode, @strRemarks,
			@strCollectCode,@strTableCode, @strCompanyCode, @intDiscountMode, @dblGlobalDiscountRate, @dblGlobalDiscountAmt,
			@dblTaxAmt)


		END
		ELSE
		BEGIN
			update tblPayment_Order set 
			Payment_GrossAmt = @dblGrossAmt, Payment_NetAmt = @dblNetAmount, Payment_RoundUp = @dblRoundUp, 
			Payment_FinalAmt = @dblNetAmount, 
			Payment_TotalTaxAmt = @dblTaxAmt, Payment_Remarks = @strRemarks,
			Payment_CollectionCode = @strCollectCode, Payment_TableCode = @strTableCode,
			Payment_DiscountMode = @intDiscountMode, Payment_GlobalDiscount = @dblGlobalDiscountRate ,
			Payment_GlobalDiscountAmt = @dblGlobalDiscountAmt, 
			Payment_SST = @dblTaxAmt
			where Payment_ReceiptNo = @strOrderNumber

			set @strReceiptNo = @strOrderNumber
			--delete from tblPayment_Details where PaymentD_ReceiptNo = @strOrderNumber
			--delete from tblPayment_Extra where PaymentEx_ReceiptNo = @strOrderNumber
		END
		
		---- Check and compare item detail
		DECLARE @tblTemp_0 TABLE
		(itemCode nvarchar(50), UOM nvarchar(50), Qty int, ISPROCCESS int)

		insert into @tblTemp_0
		SELECT itemCode, UOM, SUM(Qty), 0
		FROM OPENXML (@intDoc,  N'/NewDataSet/Table1', 2)
		WITH (itemCode nvarchar(50), UOM nvarchar(50), Qty int)
		Group by itemCode,UOM
		
		--select * from  @tblTemp_0 Order by itemCode,UOM

		DECLARE @tblTemp_1 TABLE
		(itemCode_c nvarchar(50), UOM_c nvarchar(50), Qty_c int, ISPROCCESS_c int)

		insert into @tblTemp_1
		select PaymentD_ItemCode, PaymentD_UOM, SUM(PaymentD_Qty), 0 from tblPayment_Details where PaymentD_ReceiptNo = @strReceiptNo
		Group by PaymentD_ItemCode, PaymentD_UOM
		Order by PaymentD_ItemCode, PaymentD_UOM

		--select * from @tblTemp_1

		DECLARE @tblTemp_2 TABLE
		(itemCode_2 nvarchar(50), UOM_2 nvarchar(50), Qty_2 int)

		--insert into @tblTemp_2
		--select a.itemCode, a.UOM, (a.Qty - b.Qty_c) from @tblTemp_0 a
		--inner join @tblTemp_1 b on a.itemCode = b.itemCode_c and a.UOM = b.UOM_c


		--DECLARE @IS_PROCCESS AS INT
		DECLARE @strItemCode nvarchar(50) = ''
		DECLARE @strItemUOM nvarchar(50) = ''
		Declare @intNewQty int = 0
		SET @IS_PROCCESS = 0
		WHILE @IS_PROCCESS = 0 
		BEGIN
			SELECT TOP 1 @strItemCode = itemCode, @strItemUOM = UOM, @intNewQty = Qty
			FROM @tblTemp_0 WHERE ISPROCCESS = 0 Order by itemCode
			IF @@ROWCOUNT = 0
				BEGIN
					SET @IS_PROCCESS = 1
				END
			ELSE
				BEGIN
					Declare @intRecCount int = 0
					select @intRecCount = COUNT(itemCode_c) from @tblTemp_1 where itemCode_c = @strItemCode and UOM_c = @strItemUOM
					--print @intRecCount
					if @intRecCount = 0
					BEGIN
						insert into @tblTemp_2
						values (@strItemCode,@strItemUOM, @intNewQty)
					END
					ELSE
					BEGIN
						Declare @intCurrentQty int = 0
						select @intCurrentQty = Qty_c from @tblTemp_1 where itemCode_c = @strItemCode and UOM_c = @strItemUOM

						if @intNewQty <> @intCurrentQty
						BEGIN
							insert into @tblTemp_2
							values (@strItemCode,@strItemUOM, @intNewQty - @intCurrentQty)
						END
					END
					
					
					Update @tblTemp_0 set ISPROCCESS = 1
					WHERE itemCode = @strItemCode and UOM = @strItemUOM
					Update @tblTemp_1 set ISPROCCESS_c = 1
					WHERE itemCode_c = @strItemCode and UOM_c = @strItemUOM
				END

		END

		Declare @intDeletedCount int  = 0
		select @intDeletedCount = COUNT(itemCode_c) from @tblTemp_1 where ISPROCCESS_c = 0

		if @intDeletedCount <> 0
		BEGIN
			insert into @tblTemp_2
			select itemCode_c, UOM_c, Qty_c * -1 from @tblTemp_1 where ISPROCCESS_c = 0
		END

		if @strCompanyCode = 'comp02'
		BEGIN
			INSERT INTO tblPayment_Details_Print
			(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
			PaymentD_RunNo, PaymentD_Status, PaymentD_PrintStatus, PaymentD_Detail_ID, PaymentD_CompanyCode)
			select @strReceiptNo, itemCode_2, UOM_2, GETDATE(), Qty_2, GETDATE(), 
			0, (CASE WHEN Qty_2 > 0 THEN 'new' WHEN Qty_2 < 0 THEN 'delete' END),0, 0, @strCompanyCode from @tblTemp_2 


			update tblPayment_Details_Print 
		set 
		PaymentD_ItemName = Product_Desc, --(CASE d.PaymentD_UOM WHEN 'half' THEN P.Product_Desc2 ELSE P.Product_Desc END), 
		PaymentD_ItemNameChi = Product_ChiDesc, --(CASE d.PaymentD_UOM WHEN 'half' THEN P.Product_ChiDesc2 ELSE P.Product_ChiDesc END),
		PaymentD_PrinterName = P.Product_PrinterName
		from tblPayment_Details_Print d
		inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
		 where PaymentD_ReceiptNo = @strReceiptNo AND PaymentD_ItemName = '' AND PaymentD_PrinterName = ''

			Declare @strCompanyMasterPrinter nvarchar(50) = ''
			Select @strCompanyMasterPrinter = Company_MasterPrinter from tblCompany where Company_Code = @strCompanyCode


		if @strCompanyMasterPrinter <> ''
		BEGIN
			INSERT INTO tblPayment_Details_Print
			(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
			PaymentD_RunNo, PaymentD_Status, PaymentD_PrintStatus, PaymentD_Detail_ID, PaymentD_CompanyCode)
			select @strReceiptNo, itemCode_2, UOM_2, GETDATE(), Qty_2, GETDATE(), 
			0, (CASE WHEN Qty_2 > 0 THEN 'new' WHEN Qty_2 < 0 THEN 'delete' END),0, 0, @strCompanyCode from @tblTemp_2 a
			inner join tblProduct P on P.Product_ItemCode = a.itemCode_2
			inner join tblProductCategory pc on pc.ProCategory_Code = P.Product_CategoryCode
			where pc.ProCategory_Group <> 3

			update tblPayment_Details_Print set 
			PaymentD_ItemName = Product_Desc,--(CASE d.PaymentD_UOM WHEN 'half' THEN '*' + P.Product_Desc2 ELSE '*' + P.Product_Desc END), 
			PaymentD_ItemNameChi = Product_ChiDesc,--(CASE d.PaymentD_UOM WHEN 'half' THEN '*' + P.Product_ChiDesc2 ELSE P.Product_ChiDesc END),
			PaymentD_PrinterName = @strCompanyMasterPrinter
			from tblPayment_Details_Print d
			inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
			where PaymentD_ReceiptNo = @strReceiptNo AND PaymentD_ItemName = '' AND PaymentD_PrinterName = ''

		END
		END

		

		---- END Check and compare item detail

		delete from tblPayment_Details where PaymentD_ReceiptNo = @strOrderNumber
		delete from tblPayment_Extra where PaymentEx_ReceiptNo = @strOrderNumber


		--Insert Addon Data
		--- Add in Extra add on
		DECLARE @objXml_Addon XML, @intDoc_Addon INT
		SELECT @objXml_Addon = @PaymentDetailaddonXml
		EXEC sp_xml_preparedocument @intDoc_Addon OUTPUT, @objXml_Addon
	
		INSERT INTO tblPayment_Details
		(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
		PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
		PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, PaymentD_RunNo, PaymentD_DiscountMode)
		Select @strReceiptNo, itemCode, UOM, UnitPrice, ItemDiscountPercentage, ItemDiscountAmt, NetAmount, GETDATE(), Qty, GETDATE(),
		UnitCost, ItemTaxCode, ItemTaxRate, ItemTaxAmt, ID, DiscountMode from @tblTemp

		update tblPayment_Details 
		set 
		PaymentD_ItemName = Product_Desc, --(CASE d.PaymentD_UOM WHEN 'half' THEN P.Product_Desc2 ELSE P.Product_Desc END), 
		PaymentD_ItemNameChi = Product_ChiDesc, --(CASE d.PaymentD_UOM WHEN 'half' THEN P.Product_ChiDesc2 ELSE P.Product_ChiDesc END),
		PaymentD_PrinterName = P.Product_PrinterName
		from tblPayment_Details d
		inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
		 where PaymentD_ReceiptNo = @strReceiptNo

		INSERT INTO tblPayment_Extra
		(PaymentEx_ReceiptNo, PaymentEx_RunNo, PaymentEx_ItemCode, PaymentEx_ItemDesc, PaymentEx_AddOnPrice, PaymentEx_CreatedBy, PaymentEx_CreatedDate)
		select @strReceiptNo, detailid, AddOnCode, AddOnDesc, AddOnPrice, @strPOSUserCode, GETDATE()
		FROM OPENXML (@intDoc_Addon,  N'/NewDataSet/Table1', 2)
		WITH (DetailID int, AddOnCode nvarchar(50), AddOnDesc nvarchar(50), AddOnPrice money)

		update  tblTable set Table_Status = 1 where Table_Code = @strTableCode
		AND Table_CompanyCode= @strCompanyCode


			 --- Cal Service charges
	if @dblCompanySC <> 0 
	BEGIN
		Declare @dblFinalSetAmt money = 0 
		Declare @dblFinalRoundUpAmt money = 0 
		Declare @dblFinalSSTAmt money = 0 
		Declare @dblFinalSCAmt money = 0 
		select @dblFinalSetAmt = (Payment_GrossAmt- Payment_GlobalDiscountAmt), @dblFinalSSTAmt = Payment_TotalTaxAmt 
		from tblPayment_Order where Payment_ReceiptNo = @strReceiptNo

		--set @dblFinalSSTAmt = ROUND(@dblFinalSetAmt * @dblCompanySST,2)
		set @dblFinalSCAmt = ROUND(@dblFinalSetAmt * @dblCompanySC,2)

		update tblPayment_Order set 
		--Payment_SST = @dblFinalSSTAmt, 
		Payment_SC = @dblFinalSCAmt
		--Payment_TotalTaxAmt = @dblFinalSSTAmt
		where Payment_ReceiptNo = @strReceiptNo

		set @dblFinalSetAmt = @dblFinalSetAmt + (@dblFinalSCAmt) + @dblFinalSSTAmt
		select @dblFinalRoundUpAmt = dbo.fnGetRoundUp(@dblFinalSetAmt)
		update tblPayment_Order set  Payment_RoundUp = @dblFinalRoundUpAmt where Payment_ReceiptNo = @strReceiptNo

		set @dblFinalSetAmt = @dblFinalSetAmt + @dblFinalRoundUpAmt

		update tblPayment_Order set 
		Payment_FinalAmt = @dblFinalSetAmt, Payment_CompanyCode = @strCompanyCode
		where Payment_ReceiptNo = @strReceiptNo
	END

	update tblPayment_Order set Payment_CompanyCode = @strCompanyCode
	where Payment_ReceiptNo = @strReceiptNo
	Update tblPayment_Order set Payment_SST = Payment_TotalTaxAmt where Payment_ReceiptNo = @strReceiptNo
	
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
