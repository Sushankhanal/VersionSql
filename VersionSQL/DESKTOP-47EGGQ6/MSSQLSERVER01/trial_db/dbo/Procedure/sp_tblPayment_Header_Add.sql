/****** Object:  Procedure [dbo].[sp_tblPayment_Header_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Header_Add 'user001','','COUNTER1','Hallaway01',10,0,0,0,10,'',xml,'','',2,'',6,'','','',0
CREATE PROCEDURE [dbo].[sp_tblPayment_Header_Add]
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
	@strRandomKey		nvarchar(1024),
	@strQRCodeDate		nvarchar(50),
	@intUserID			int,
	@strQRCodeText		nvarchar(max),
	@intPaymentType		int,
	@strPaymentTypeRemarks	nvarchar(50),
	@strReceiptNo		nvarchar(50) OUT,
	@strClientFullName	nvarchar(50) OUT,
	@strClientBalance	money OUT,
	@PaymentDetailAddOnXml	XML,
	@RedeemPoint		money,
	@RedeemAmt			money,
	@strClientPoint		money OUT,
	@intDiscountMode	smallint, -- 0: Amount, 1 Percentage,
	@strCollectCode		nvarchar(50),
	@dblCollectedAmt	money,
	@dblGlobalDiscountAmt	money,
	@strTableCode			nvarchar(50),
	@strOrderNumber			nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @dblCompanySST money = 0
	Declare @dblCompanySC money = 0
	Select @dblCompanySST = Company_SST, @dblCompanySC = Company_SC from tblCompany where Company_Code = @strCompanyCode
	if @dblCompanySST = 0 and @dblCompanySC = 0
	BEGIN
		Select @dblCompanySST = Counter_SST, @dblCompanySC = Counter_SC from tblCounter where Counter_Code = @strCounterCode
		AND Counter_CompanyCode = @strCompanyCode
	END

	set @dblCompanySST = (@dblCompanySST / 100)
	set @dblCompanySC = (@dblCompanySC / 100)

	if @strOrderNumber = '0' BEGIN set @strOrderNumber = '' END

	--DECLARE @strClientUserCode nvarchar(50)
	DECLARE @strClientRandomCode nvarchar(1024)
	set @strClientUserCode = ''
	set @strClientRandomCode = ''
	set @strClientBalance = 0
	set @strClientPoint = 0
	set @strClientFullName = ''
	select @strClientUserCode = mUser_Code, @strClientRandomCode = ISNULL(mUser_RandomCode,''),
	@strClientFullName = mUser_FullName, @strClientBalance = mUser_TotalBalance,
	@strClientPoint = mUser_TotalPoint
	from tblUserMobile where mUser_ID = @intUserID
	

	if @strClientUserCode = ''
	BEGIN
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		RETURN (-6)
	END
	-- Temp Off
	if @strClientRandomCode <> @strRandomKey
	BEGIN
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		RETURN (-7)
	END

	--- Check enuf point or not
	if @RedeemPoint <> 0
	BEGIN
		if @RedeemPoint > @strClientPoint
		BEGIN
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (-9)
		END
	END

	Declare @intWalletTransType int

	--- Check Item got mix the product sign or not
		DECLARE @objXml XML, @intDoc INT
		SELECT @objXml = @PaymentDetailXml
		--print convert(nvarchar(max),@objXml)
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

		if (SELECT ISNULL(COUNT(ID), 0) FROM @tblTemp ) = 0
		BEGIN
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (-8)
		END

		Update @tblTemp set ItemSign = WT.WTransType_Sign, WalletTransType = P.Product_WalletsTransType
		From @tblTemp t inner join tblProduct P on t.itemCode = P.Product_ItemCode
		inner join tblWalletTransType WT on P.Product_WalletsTransType = WT.WTransType_ID

		select @@ROWCOUNT from @tblTemp Group by ItemSign

		DECLARE @intCount_Mix int
		DECLARE @intItemSign int
		select @intCount_Mix = @@ROWCOUNT from @tblTemp Group by ItemSign
		print @intCount_Mix
		if @intCount_Mix > 1
		BEGIN
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (-8)
		END
		ELSE
		BEGIN
			select @intItemSign = ItemSign, @intWalletTransType = WalletTransType from @tblTemp Group by ItemSign, WalletTransType

		END
		
		--- Added by Hong
		Declare @dblTotalNet_Detail money = 0
		select @dblTotalNet_Detail = SUM(NetAmount) from @tblTemp

		DECLARE @objXml_Addon2 XML, @intDoc_Addon2 INT
		SELECT @objXml_Addon2 = @PaymentDetailaddonXml
		EXEC sp_xml_preparedocument @intDoc_Addon2 OUTPUT, @objXml_Addon2
		DECLARE @tblExtraSUM TABLE
		(DetailID bigint, ExtraSum money)

		INSERT INTO @tblExtraSUM
		(DetailID, ExtraSum)
		select detailid, AddOnPrice
		FROM OPENXML (@intDoc_Addon2,  N'/NewDataSet/Table1', 2)
		WITH (DetailID int, AddOnPrice money)

		Declare @dblTotalNet_Extra money = 0
		select @dblTotalNet_Extra = SUM(ExtraSum) from @tblExtraSUM
		set @dblTotalNet_Detail = @dblTotalNet_Detail + @dblTotalNet_Extra
		if @dblTotalNet_Detail <> @dblGrossAmt
		BEGIN
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (-8)
		END


		--- END Check Item got mix the product sign or not

		DECLARE @dblWalletBalance money
		DECLARE @strWalletCode nvarchar(50)
		select @dblWalletBalance = UWallet_Balance, @strWalletCode = UWallet_Code
		from tblUserWallet where UWallet_UserCode = @strClientUserCode

		set @strClientBalance = @dblWalletBalance
		--set @strClientPoint = 0
		select @strClientPoint = mUser_TotalPoint from tblUserMobile 
		where mUser_Code = @strClientUserCode

		if @intItemSign = -1 -- Minus Case
		BEGIN
			--set @intWalletTransType = 2 -- Purchase
			--@strClientBalance
		

			if @dblWalletBalance < @dblNetAmount
			BEGIN
				ROLLBACK TRANSACTION
				SET NOCOUNT OFF
				RETURN (-1)
			END
		END
	

	
	--ELSE
	--BEGIN
		

		--select * from @tblTemp

		DECLARE @IS_PROCCESS AS INT

		DECLARE @PrefixType VARCHAR(50), @intRowCount INT
		--Declare @strReceiptNo nvarchar(50)
		set @PrefixType = 'Wallet Receipt'
		EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strReceiptNo OUTPUT
	
		--Declare @intPaymentType int
		--set @intPaymentType = 6
		Declare @dblReturnAmt money = 0
		set @dblReturnAmt = @dblNetAmount - @dblCollectedAmt

		INSERT INTO tblPayment_Header
		(Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, Payment_FinalAmt, 
		Payment_CounterCode, Payment_PaymentType, Payment_PayAmt, Payment_ReturnAmt, 
		Payment_Status, Payment_CreatedDate, Payment_CardNumber, Payment_CardType, Payment_RefundCode, 
		Payment_UserCode, Payment_GlobalDiscount, Payment_GlobalDiscountAmt, Payment_AdjustmentAmt, 
		Payment_IsSettlement, Payment_TotalTaxAmt, Payment_CreatedBy, Payment_Remarks, Payment_RedeemAmt, 
		Payment_RedeemPoint, Payment_DiscountMode, Payment_CollectionCode, Payment_TableCode)
		VALUES (
		@strReceiptNo,GETDATE(),@dblGrossAmt,0,@dblNetAmount,@dblRoundUp,@dblNetAmount,
		@strCounterCode,@intPaymentType,@dblCollectedAmt,@dblReturnAmt,
		0,GETDATE(),@strPaymentTypeRemarks,0,'',
		@strClientUserCode,@dblGlobalDiscountRate,@dblGlobalDiscountAmt,0,0,@dblTaxAmt, @strPOSUserCode, @strRemarks, 
		@RedeemAmt, @RedeemPoint, @intDiscountMode, @strCollectCode, @strTableCode)

		INSERT INTO tblPayment_Details
		(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
		PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
		PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, PaymentD_RunNo, PaymentD_DiscountMode)
		Select @strReceiptNo, itemCode, UOM, UnitPrice, ItemDiscountPercentage, ItemDiscountAmt, NetAmount, GETDATE(), Qty, GETDATE(),
		UnitCost, ItemTaxCode, ItemTaxRate, ItemTaxAmt, ID, DiscountMode from @tblTemp
		--select @@IDENTITY

		-- Added By Ricky -- 15/11/2019
		update tblPayment_Details 
		set 
		PaymentD_ItemName = Product_Desc, --(CASE d.PaymentD_UOM WHEN 'half' THEN P.Product_Desc2 ELSE P.Product_Desc END), 
		PaymentD_ItemNameChi = Product_ChiDesc, -- (CASE d.PaymentD_UOM WHEN 'half' THEN P.Product_ChiDesc2 ELSE P.Product_ChiDesc END),
		PaymentD_PrinterName = P.Product_PrinterName
		from tblPayment_Details d
		inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
		 where PaymentD_ReceiptNo = @strReceiptNo

		--Insert Addon Data
		--- Add in Extra add on
		DECLARE @objXml_Addon XML, @intDoc_Addon INT
		SELECT @objXml_Addon = @PaymentDetailaddonXml
		EXEC sp_xml_preparedocument @intDoc_Addon OUTPUT, @objXml_Addon
	
		INSERT INTO tblPayment_Extra
		(PaymentEx_ReceiptNo, PaymentEx_RunNo, PaymentEx_ItemCode, PaymentEx_ItemDesc, PaymentEx_AddOnPrice, PaymentEx_CreatedBy, PaymentEx_CreatedDate)
		select @strReceiptNo, detailid, AddOnCode, AddOnDesc, AddOnPrice, @strPOSUserCode, GETDATE()
		FROM OPENXML (@intDoc_Addon,  N'/NewDataSet/Table1', 2)
		WITH (DetailID int, AddOnCode nvarchar(50), AddOnDesc nvarchar(50), AddOnPrice money)

		--if @intPaymentType = 6
		--BEGIN
		Declare @dblTotalItemAmount money
			select @dblTotalItemAmount = SUM(NetAmount) from  @tblTemp
			set @dblTotalItemAmount = @dblTotalItemAmount - @RedeemAmt

			INSERT INTO tblWalletTrans
			(WalletTrans_Code, WalletTrans_UserCode, WalletTrans_WalletCode, WalletTrans_Type, 
			WalletTrans_Value, WalletTrans_MoneyValue, WalletTrans_RefCode, WalletTrans_Remarks, 
			WalletTrans_CreatedBy, WalletTrans_CreatedDate, 
			WalletTrans_CampaignCode, WalletTrans_PaymentMode, WalletTrans_QRCodeText)
			VALUES (
			@strReceiptNo,@strClientUserCode,@strWalletCode,@intWalletTransType,
			@dblTotalItemAmount * @intItemSign,@dblTotalItemAmount,@strReceiptNo,@strRemarks,
			@strPOSUserCode,GETDATE(),'',@intPaymentType, @strQRCodeText)

			Declare @dblFinalNetAmount money
			set @dblFinalNetAmount = @dblTotalItemAmount * @intItemSign -- Make it negative if minus
			--print @intItemSign
			--print @dblFinalNetAmount

			update tblUserWallet set UWallet_Balance = UWallet_Balance + @dblFinalNetAmount where UWallet_Code = @strWalletCode
			 
			select @dblWalletBalance = UWallet_Balance from tblUserWallet where UWallet_UserCode = @strClientUserCode

			set @strClientBalance = @dblWalletBalance
			
			--Redeem Point
			if @RedeemPoint <> 0
			BEGIN
				Declare @dblCurrentPoint money
				select @dblCurrentPoint = mUser_TotalPoint from tblUserMobile 
				where mUser_Code = @strClientUserCode
				
				if @RedeemPoint > @dblCurrentPoint
				BEGIN
					ROLLBACK TRANSACTION
					SET NOCOUNT OFF
					RETURN (-9)
				END
				ELSE
				BEGIN
					Declare @intRedeemType int
					declare @strClientPointRedeemRate money
					set @intRedeemType = 11
					set @strClientPointRedeemRate = 0
					select @strClientPointRedeemRate = WTransType_DefaultPointRate 
					from tblWalletTransType  where WTransType_Name ='Redeem'

					INSERT INTO tblPointTrans
					(PointTrans_Code, PointTrans_UserCode, PointTrans_Type, PointTrans_Value, PointTrans_PointValue, 
					PointTrans_RefCode, PointTrans_Remarks, PointTrans_CreatedBy, PointTrans_CreatedDate, PointTrans_CampaignCode, 
					PointTrans_QRCodeText, PointTrans_WalletAmt, PointTrans_Ratio)
					VALUES (
					@strReceiptNo,@strClientUserCode,@intRedeemType,@RedeemPoint * -1,@RedeemPoint,
					@strReceiptNo,@strRemarks,@strPOSUserCode,GETDATE(),'',
					@strQRCodeText,@RedeemAmt,@strClientPointRedeemRate)

					Update tblUserMobile set
					mUser_TotalPoint = mUser_TotalPoint - @RedeemPoint 
					where mUser_Code = @strClientUserCode
				END

			END

			if @intPaymentType <> 2
			BEGIN
				-- Calc point
				Declare @dblDefaultPointRate money = 0
				select @dblDefaultPointRate = WTransType_DefaultPointRate  from tblWalletTransType 
				where WTransType_ID = @intWalletTransType
			
				Declare @dblTotalPointEarn money = 0
				set @dblTotalPointEarn = @dblTotalItemAmount * @dblDefaultPointRate

				if @dblDefaultPointRate <> 0
				BEGIN
					if @dblTotalPointEarn <> 0
					BEGIN
						INSERT INTO tblPointTrans
						(PointTrans_Code, PointTrans_UserCode, PointTrans_Type, PointTrans_Value, PointTrans_PointValue, 
						PointTrans_RefCode, PointTrans_Remarks, PointTrans_CreatedBy, PointTrans_CreatedDate, PointTrans_CampaignCode, 
						PointTrans_QRCodeText, PointTrans_WalletAmt, PointTrans_Ratio)
						VALUES (
						@strReceiptNo,@strClientUserCode,@intWalletTransType,@dblTotalPointEarn,@dblTotalPointEarn,
						@strReceiptNo,@strRemarks,@strPOSUserCode,GETDATE(),'',
						@strQRCodeText,@dblNetAmount,@dblDefaultPointRate)

						Update tblUserMobile set 
						mUser_TotalPoint = mUser_TotalPoint + @dblTotalPointEarn 
						where mUser_Code = @strClientUserCode
					END

					
				END

			END

			Update tblUserMobile set mUser_RandomCode = NULL, 
			mUser_TotalBalance = @strClientBalance
			where mUser_Code = @strClientUserCode

			select @strClientPoint = mUser_TotalPoint from tblUserMobile 
			where mUser_Code = @strClientUserCode
			

		 --- Cal Service charges
		if @dblCompanySC <> 0 
		BEGIN
			Declare @dblFinalSetAmt money = 0 
			Declare @dblFinalRoundUpAmt money = 0 
			Declare @dblFinalSSTAmt money = 0 
			Declare @dblFinalSCAmt money = 0 
			select @dblFinalSetAmt = (Payment_GrossAmt- Payment_DiscountAmt-Payment_GlobalDiscountAmt), @dblFinalSSTAmt = Payment_TotalTaxAmt from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo

			--set @dblFinalSSTAmt = ROUND(@dblFinalSetAmt * @dblCompanySST,2)
			set @dblFinalSCAmt = ROUND(@dblFinalSetAmt * @dblCompanySC,2)

			update tblPayment_Header set 
			--Payment_SST = @dblFinalSSTAmt, 
			Payment_SC = @dblFinalSCAmt
			--Payment_TotalTaxAmt = @dblFinalSSTAmt
			where Payment_ReceiptNo = @strReceiptNo

			set @dblFinalSetAmt = @dblFinalSetAmt + (@dblFinalSCAmt) + @dblFinalSSTAmt
			select @dblFinalRoundUpAmt = dbo.fnGetRoundUp(@dblFinalSetAmt)
			update tblPayment_Header set  Payment_RoundUp = @dblFinalRoundUpAmt where Payment_ReceiptNo = @strReceiptNo

			set @dblFinalSetAmt = @dblFinalSetAmt + @dblFinalRoundUpAmt

			update tblPayment_Header set 
			Payment_FinalAmt = @dblFinalSetAmt, Payment_CompanyCode = @strCompanyCode
			where Payment_ReceiptNo = @strReceiptNo
		END

		update tblPayment_Header set Payment_CompanyCode = @strCompanyCode

		--END

		
		 
		--COMMIT TRANSACTION
		--SET NOCOUNT OFF
		--RETURN (0)
	--END
	if @strOrderNumber <> ''
	BEGIN
		--Delete from tblPayment_Order where Payment_ReceiptNo = @strOrderNumber
		--Delete from tblPayment_Details where PaymentD_ReceiptNo = @strOrderNumber
		--Delete from tblPayment_Extra where PaymentEx_ReceiptNo = @strOrderNumber
		Update tblPayment_Order set Payment_Status = 1 where Payment_ReceiptNo = @strOrderNumber
	END
	Update tblPayment_Header set Payment_SST = Payment_TotalTaxAmt where Payment_ReceiptNo = @strReceiptNo
	Update tblTable set Table_Status = 0, Table_isCalling = 0 where Table_Code = @strTableCode and Table_CompanyCode = @strCompanyCode

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
