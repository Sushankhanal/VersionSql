/****** Object:  Procedure [dbo].[sp_tblPayment_Order_Get]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec sp_tblPayment_Order_Get 'Counter-02','Hallaway01',''
CREATE PROCEDURE [dbo].[sp_tblPayment_Order_Get] (
	@CounterCode	nvarchar(50),
	@CompanyCode	nvarchar(50),
	@strReceiptNo	nvarchar(50)
) AS
BEGIN
	
	if @CompanyCode = 'Hallaway01'
	BEGIN
		select Payment_ID, Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, 
		Payment_FinalAmt, 
		Payment_UserCode, 
		Payment_TotalTaxAmt, Payment_Remarks,
		(CASE ISNULL(UM.mUser_FullName,'') WHEN '' THEN H.Payment_UserCode ELSE UM.mUser_FullName END) as ClientName,
		H.Payment_TableCode as TableCode, Payment_CompanyCode, Payment_CollectionCode
		, ISNULL((select top 1 Table_Name from tblTable where Table_Code = H.Payment_TableCode AND Table_CompanyCode = @CompanyCode),'') as TableName
		, Payment_DiscountMode,Payment_GlobalDiscount, Payment_GlobalDiscountAmt

		from tblPayment_Order H
		--inner join tblPaymentMode PM on H.Payment_PaymentType = PM.PaymentMode_ID
		left outer join tblUserMobile UM on H.Payment_UserCode = UM.mUser_Code
		where Payment_ReceiptNo  LIKE '%' + @strReceiptNo + '%'
		AND Payment_CompanyCode = @CompanyCode
		AND Payment_Status = 0
		AND Payment_CounterCode LIKE '%' + @CounterCode + '%'
		Order by Payment_ReceiptNo

	END
	ELSE
	BEGIN
		select Payment_ID, Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, 
		Payment_FinalAmt, 
		Payment_UserCode, 
		Payment_TotalTaxAmt, Payment_Remarks,
		(CASE ISNULL(UM.mUser_FullName,'') WHEN '' THEN H.Payment_UserCode ELSE UM.mUser_FullName END) as ClientName,
		H.Payment_TableCode as TableCode, Payment_CompanyCode, Payment_CollectionCode
		, ISNULL((select top 1 Table_Name from tblTable where Table_Code = H.Payment_TableCode AND Table_CompanyCode = @CompanyCode),'') as TableName
		, Payment_DiscountMode,Payment_GlobalDiscount, Payment_GlobalDiscountAmt
		from tblPayment_Order H
		--inner join tblPaymentMode PM on H.Payment_PaymentType = PM.PaymentMode_ID
		left outer join tblUserMobile UM on H.Payment_UserCode = UM.mUser_Code
		where Payment_ReceiptNo  LIKE '%' + @strReceiptNo + '%'
		AND Payment_CompanyCode = @CompanyCode
		AND Payment_Status = 0
		Order by Payment_ReceiptNo
	END

	
	if @strReceiptNo <> ''
	BEGIN
		
		  --dr("detailid") = 1
    --        dr("itemCode") = "P0551" '"P0010" '"P0010"
    --        dr("UOM") = "Unit"
    --        dr("UnitPrice") = 8.9
    --        dr("Qty") = 1
    --        dr("ItemDiscountAmt") = 0
    --        dr("ItemDiscountPercentage") = 0
    --        dr("ItemTaxCode") = "ZR"
    --        dr("ItemTaxRate") = 0
    --        dr("ItemTaxAmt") = 0
    --        dr("NetAmount") = 8.9
    --        dr("DiscountMode") = 0

		update T
		set PaymentD_RunNo = rn
		from (
		   select PaymentD_RunNo,
				  ROW_NUMBER() OVER(ORDER BY C.PaymentD_ID)  as rn
		   from tblPayment_Details C where C.PaymentD_ReceiptNo = @strReceiptNo
		 ) T

		if @CompanyCode = 'comp02'
		BEGIN
			Update tblPayment_Details set PaymentD_DeviceCode = '' where PaymentD_ReceiptNo =  @strReceiptNo
		END

		Select PaymentD_RunNo as DetailID,
		PaymentD_ItemCode as itemCode, 
		(CASE Product_ChiDesc WHEN '' THEN Product_Desc ELSE (Product_ChiDesc + ' (' + Product_Desc + ')') END) as Product_Desc, 
		PaymentD_UOM as UOM, 
		PaymentD_UnitPrice AS UnitPrice, 
		PaymentD_Qty as Qty, 
		PaymentD_DiscountAmt as ItemDiscountAmt, 
		PaymentD_DiscountPercent as ItemDiscountPercentage, 
		PaymentD_TaxCode as ItemTaxCode, 
		PaymentD_TaxRate as ItemTaxRate, 
		PaymentD_TaxAmt as ItemTaxAmt, 
		Paymentd_DiscountMode as DiscountMode,
		(PaymentD_UnitPrice * PaymentD_Qty) as NetAmount,
		PaymentD_ID
		--PaymentD_ReceiptNo as OrderNumber
		--ISNULL(dbo.fnCombineAllAddOn(PaymentD_ReceiptNo,PaymentD_RunNo),'') as AddOnValue  
		from tblPayment_Details PD
		inner join tblProduct P on PD.PaymentD_ItemCode = P.Product_ItemCode
		where PaymentD_ReceiptNo = @strReceiptNo
		Order by PaymentD_RunNo

		  --'dr_Ex("detailid") = 1
    --            'dr_Ex("AddOnCode") = "Addon001"
    --            'dr_Ex("AddOnDesc") = "Black Pepper Sauce"
    --            'dr_Ex("AddOnPrice") = 0          
    --            'dt_Ex.Rows.Add(dr_Ex)

		--DECLARE @tblPayment_Extra TABLE
		--(PaymentEx_ID bigint, PaymentEx_ReceiptNo nvarchar(50), DetailID int, PaymentEx_ItemCode nvarchar(50), 
		--PaymentEx_ItemDesc nvarchar(100), PaymentEx_AddOnPrice money, 
		--PaymentEx_CreatedBy nvarchar(50), PaymentEx_CreatedDate datetime)

		DECLARE @tblPayment_Extra TABLE
		(DetailID bigint, AddOnCode nvarchar(50), AddOnDesc nvarchar(50), AddOnPrice money)

		insert into @tblPayment_Extra
		SELECT PaymentEx_RunNo as DetailID, PaymentEx_ItemCode, PaymentEx_ItemDesc, PaymentEx_AddOnPrice
		--, PaymentEx_ReceiptNo
		FROM     tblPayment_Extra where PaymentEx_ReceiptNo = @strReceiptNo
		Order by PaymentEx_RunNo

		select * from @tblPayment_Extra
	END

END
