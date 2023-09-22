/****** Object:  Procedure [dbo].[sp_tblPayment_GetByReceiptNo_Print]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec sp_tblPayment_GetByReceiptNo_Print 'COUNTER4', 'Hallaway01', 'RE00000112'
CREATE PROCEDURE [dbo].[sp_tblPayment_GetByReceiptNo_Print] (
	@CounterCode	nvarchar(50),
	@CompanyCode	nvarchar(50),
	@strReceiptNo	nvarchar(50)
) AS
BEGIN
	
	Update tblPayment_Details set PaymentD_ItemName = P.Product_Desc, PaymentD_ItemNameChi = P.Product_ChiDesc
	from tblPayment_Details d (NOLOCK)
	inner join tblProduct P on P.Product_ItemCode = d.PaymentD_ItemCode
	where PaymentD_ItemName = ''
	
select Payment_ID, Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, 
	Payment_FinalAmt, Payment_PaymentType, Payment_PayAmt, 
	Payment_ReturnAmt, Payment_CardNumber, Payment_CardType, 
	Payment_UserCode, Payment_GlobalDiscountAmt, Payment_AdjustmentAmt, 
	Payment_TotalTaxAmt, PM.PaymentMode_Name, Payment_Remarks,
	(CASE Payment_IsRefund WHEN 1 THEN 'Voided' WHEN 2 THEN 'Void receipt' ELSE '' END) as RefundStatus,
	(CASE ISNULL(UM.mUser_FullName,'') WHEN '' THEN H.Payment_UserCode ELSE UM.mUser_FullName END) as ClientName,
	Company_Name, Company_RegNo, Company_Address1, Company_Address2, PM.PaymentMode_Name,

	(CASE WHEN Payment_DiscountMode = 0 AND Payment_GlobalDiscount <> 0 then 
	'Dis@' + Convert(nvarchar(50), Convert(decimal(18,2), Payment_GlobalDiscount)) + '%'
	WHEN Payment_DiscountMode = 1 AND Payment_GlobalDiscountAmt <> 0 then 
	'Dis@RM' + Convert(nvarchar(50), Convert(decimal(18,2), Payment_GlobalDiscountAmt))
	ELSE 'Dis'
	END) as GlobalDiscountText,
	Payment_RedeemAmt, Payment_RedeemPoint, Payment_CollectionCode,
	Payment_PayAmt as Payment_CollectedAmt, Payment_ReturnAmt as Payment_ChangeAmt,
	ISNULL((select top 1 Table_Name from tblTable where Table_Code = H.Payment_TableCode),'') as TableName,
	Payment_SST, Payment_SC,

	ISNULL((select top 1 CardTrans_SerialNo from tblCard_Trans where CardTrans_Code = h.Payment_ReceiptNo),'') as MemberCardNumber,
	ISNULL((select um1.mUser_FullName from tblWalletTrans w1
	inner join tblUserMobile um1 on w1.WalletTrans_UserCode = um1.mUser_Code where WalletTrans_Code = h.Payment_ReceiptNo),'') as MobileMemberName
	--MemberCardNumber,MobileMemberName,PaymentMode_Name
	from tblPayment_Header H
	inner join tblPaymentMode PM on H.Payment_PaymentType = PM.PaymentMode_ID
	left outer join tblUserMobile UM on H.Payment_UserCode = UM.mUser_Code
	inner join tblCounter CC on CC.Counter_Code = H.Payment_CounterCode
	inner join tblCompany C on C.Company_Code = CC.Counter_CompanyCode
	where Payment_CounterCode = @CounterCode
	AND Payment_ReceiptNo = @strReceiptNo
	Order by Payment_ReceiptNo

	Select PaymentD_ReceiptNo, PaymentD_ItemCode, 
	--P.Product_Desc, 
	--(CASE PaymentD_ItemNameChi WHEN '' THEN PaymentD_ItemName ELSE (PaymentD_ItemName + ' (' + PaymentD_ItemNameChi + ')') END) as Product_Desc, 
	PaymentD_ItemName as Product_Desc,
	PaymentD_UOM, PaymentD_UnitPrice, PaymentD_Qty, PaymentD_DiscountPercent, 
	PaymentD_DiscountAmt, 
	(PaymentD_UnitPrice * PaymentD_Qty) as PaymentD_NetAmount, 
	PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, 
	PaymentD_RunNo as DetailID, 
	ISNULL(dbo.fnCombineAllAddOn(PaymentD_ReceiptNo,PaymentD_RunNo),'') as AddOnValue,
	--,P.Product_PrinterName  
	PaymentD_PrinterName as Product_PrinterName
	from tblPayment_Details PD
	--inner join tblProduct P on PD.PaymentD_ItemCode = P.Product_ItemCode
	where PaymentD_ReceiptNo = @strReceiptNo

	DECLARE @tblPayment_Extra TABLE
    (PaymentEx_ID bigint, PaymentEx_ReceiptNo nvarchar(50), DetailID int, PaymentEx_ItemCode nvarchar(50), 
	PaymentEx_ItemDesc nvarchar(100), PaymentEx_AddOnPrice money, 
	PaymentEx_CreatedBy nvarchar(50), PaymentEx_CreatedDate datetime)

	insert into @tblPayment_Extra
	SELECT PaymentEx_ID, PaymentEx_ReceiptNo, PaymentEx_RunNo as DetailID, PaymentEx_ItemCode, PaymentEx_ItemDesc, PaymentEx_AddOnPrice, 
	PaymentEx_CreatedBy, PaymentEx_CreatedDate
	FROM     tblPayment_Extra where PaymentEx_ReceiptNo = @strReceiptNo
	Order by PaymentEx_RunNo

	DECLARE @tblTemp TABLE
    (RowNo int, PaymentD_RunNo int, PaymentD_DiscountPercent money, PaymentD_DiscountAmt money, PaymentD_DiscountMode int, ISPROCCESS INT)

	insert into @tblTemp
	select ROW_NUMBER() OVER(ORDER BY PaymentD_ID DESC) AS RowNo,
	PaymentD_RunNo, PaymentD_DiscountPercent, PaymentD_DiscountAmt, PaymentD_DiscountMode, 0
	from tblPayment_Details PD
	where PaymentD_ReceiptNo = @strReceiptNo
	AND PaymentD_DiscountAmt <> 0

	DECLARE @IS_PROCCESS AS INT
	DECLARE @intDiscountMode int
	DECLARE @intID int
	DECLARE @dblDisPercent money
	DECLARE @dblDisAmt money
	DECLARE @strDiscountDesc nvarchar(100) = ''
	DECLARE @strDiscountCode nvarchar(50) = 'Discount'
	DECLARE @intRunNo int
	DECLARE @dblDisAmtFinal money = 0

	SET @IS_PROCCESS = 0
	WHILE @IS_PROCCESS = 0 
	BEGIN
		SELECT TOP 1 @intID = RowNo, @intDiscountMode = PaymentD_DiscountMode,
		@dblDisPercent = PaymentD_DiscountPercent, @dblDisAmt = PaymentD_DiscountAmt,
		@intRunNo = PaymentD_RunNo
		FROM @tblTemp WHERE ISPROCCESS = 0 Order by RowNo
		IF @@ROWCOUNT = 0
			BEGIN
				SET @IS_PROCCESS = 1
			END
		ELSE
			BEGIN
				set @strDiscountDesc = ''
				if @intDiscountMode = 0
				BEGIN
					set @strDiscountDesc = 'Dis@' + Convert(nvarchar(50), Convert(decimal(18,2), @dblDisPercent)) + '%'
				END
				ELSE
				BEGIN
					set @strDiscountDesc = 'Dis@RM' + Convert(nvarchar(50), Convert(decimal(18,2), @dblDisAmt))
				END
				set @dblDisAmtFinal = @dblDisAmt * -1

				insert into @tblPayment_Extra
				SELECT 0, @strReceiptNo, @intRunNo, @strDiscountCode, @strDiscountDesc, @dblDisAmtFinal, 
				'SYSTEM', GETDATE()
				
				UPDATE @tblTemp SET 
				ISPROCCESS = 1
				WHERE RowNo = @intID

			END
	END

	select * from @tblPayment_Extra


END
