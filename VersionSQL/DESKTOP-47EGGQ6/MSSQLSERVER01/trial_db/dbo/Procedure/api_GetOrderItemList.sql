/****** Object:  Procedure [dbo].[api_GetOrderItemList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory('')
--exec api_GetFoodCategory(''

CREATE PROCEDURE [dbo].[api_GetOrderItemList] (
	@strDeviceCode	nvarchar(50),
	@strCategoryCode	nvarchar(50), 
	@strCompanyCode	nvarchar(50),
	@strOrderNo		nvarchar(50)
) AS
BEGIN

	Update tblPayment_Details set PaymentD_ItemName = P.Product_Desc, PaymentD_ItemNameChi = P.Product_ChiDesc
	from tblPayment_Details d (NOLOCK)
	inner join tblProduct P on P.Product_ItemCode = d.PaymentD_ItemCode
	where PaymentD_ItemName = ''

	select ROW_NUMBER() OVER(ORDER BY PaymentD_RunNo)  AS RowNo,
	PaymentD_ItemName as Product_Desc, PaymentD_ItemNameChi as Product_ChiDesc, 
	--P.Product_Desc, P.Product_ChiDesc, 
	D.PaymentD_UnitPrice, D.PaymentD_Qty, D.PaymentD_NetAmount,
	D.PaymentD_UOM,
	(select (CASE D.PaymentD_UOM when 'half' then Product_HalfDesc ELSE Product_FullDesc END) from tblProduct where Product_ItemCode = D.PaymentD_ItemCode) as UOM_Desc
	from tblPayment_Details D
	--inner join tblProduct P on D.PaymentD_ItemCode = P.Product_ItemCode
	where PaymentD_ReceiptNo = @strOrderNo
	Order by PaymentD_RunNo

END
