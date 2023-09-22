/****** Object:  Procedure [dbo].[api_GetProductList_POS]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec api_GetProductList_POS 'POS-01','comp02',''
CREATE PROCEDURE [dbo].[api_GetProductList_POS] (
	@CounterCode	nvarchar(50),
	@BranchCode		nvarchar(50),
	@ProductCategory	nvarchar(50)
) AS
BEGIN
	Declare @intCounterID bigint = 0
	select @intCounterID = Counter_ID from tblCounter where Counter_Code = @CounterCode

	if @ProductCategory = ''
	BEGIN
		select Product_ItemCode, 
		(CASE Product_ChiDesc WHEN '' THEN Product_Desc ELSE (Product_ChiDesc + ' (' + Product_Desc + ')') END) as Product_Desc, 
		Product_UOM, Product_UnitPrice, Product_Status, Product_CategoryCode,NULL as Product_img,
		--(CASE Product_WalletsTransType WHEN 1 THEN 1 ELSE 0 END) as Product_isTopUpItem
		w.WTransType_Sign as Product_isTopUpItem,
		'Half' as UOM_Half, 'Full' as UOM_Full, 
		Product_UnitPrice as UnitPrice_Full, Product_UnitPrice2 as UnitPrice_Half,
		Product_Desc2 as Product_Desc_Half, Product_ChiDesc2 as Product_ChiDesc_Half,
		Product_TaxRate
		from tblProduct p
		inner join tblProductCategory pc on p.Product_CategoryCode = pc.ProCategory_Code
		inner join tblWalletTransType w on w.WTransType_ID = p.Product_WalletsTransType
		where p.Product_BranchCode = @BranchCode
		AND p.Product_Status = 0 
		Order by Product_Desc
	END
	ELSE
	BEGIN
		select Product_ItemCode, 
		(CASE Product_ChiDesc WHEN '' THEN Product_Desc ELSE (Product_ChiDesc + ' (' + Product_Desc + ')') END) as Product_Desc, 
		Product_UOM, Product_UnitPrice, Product_Status, Product_CategoryCode, NULL as Product_img,
		--(CASE Product_WalletsTransType WHEN 1 THEN 1 ELSE 0 END) as Product_isTopUpItem
		w.WTransType_Sign as Product_isTopUpItem,
		'Half' as UOM_Half, 'Full' as UOM_Full, 
		Product_UnitPrice as UnitPrice_Full, Product_UnitPrice2 as UnitPrice_Half,
		Product_Desc2 as Product_Desc_Half, Product_ChiDesc2 as Product_ChiDesc_Half
		from tblProduct p
		inner join tblProductCategory pc on p.Product_CategoryCode = pc.ProCategory_Code
		inner join tblWalletTransType w on w.WTransType_ID = p.Product_WalletsTransType
		where p.Product_BranchCode = @BranchCode
		AND p.Product_Status = 0
		AND pc.ProCategory_Code = @ProductCategory
		Order by Product_Desc
	END

	
END
