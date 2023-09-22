/****** Object:  Procedure [dbo].[sp_tblProduct_get]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec sp_tblProduct_get 'COUNTER1','Hallaway01',''
CREATE PROCEDURE [dbo].[sp_tblProduct_get] (
	@CounterCode	nvarchar(50),
	@BranchCode		nvarchar(50),
	@ProductCategory	nvarchar(50)
) AS
BEGIN
	Declare @intCounterID bigint = 0
	select @intCounterID = Counter_ID from tblCounter where Counter_Code = @CounterCode

	if @ProductCategory = ''
	BEGIN
		select Product_ItemCode, Product_Desc, Product_UOM, Product_UnitPrice, Product_Status, Product_CategoryCode, Product_img, Product_TaxRate,
		--(CASE Product_WalletsTransType WHEN 1 THEN 1 ELSE 0 END) as Product_isTopUpItem
		w.WTransType_Sign as Product_isTopUpItem
		from tblProduct p
		inner join tblProductCategory pc on p.Product_CategoryCode = pc.ProCategory_Code
		inner join tblWalletTransType w on w.WTransType_ID = p.Product_WalletsTransType
		where p.Product_BranchCode = @BranchCode
		AND p.Product_Status = 0 
		AND Product_ItemCode in (select ProductCounter_ProductCode from tblProductCounter WHERE ProductCounter_CounterID = @intCounterID)
		--AND pc.ProCategory_Code = @ProductCategory
		Order by Product_ItemCode
	END
	ELSE
	BEGIN
		select Product_ItemCode, Product_Desc, Product_UOM, Product_UnitPrice, Product_Status, Product_CategoryCode, Product_img, Product_TaxRate,
		--(CASE Product_WalletsTransType WHEN 1 THEN 1 ELSE 0 END) as Product_isTopUpItem
		w.WTransType_Sign as Product_isTopUpItem
		from tblProduct p
		inner join tblProductCategory pc on p.Product_CategoryCode = pc.ProCategory_Code
		inner join tblWalletTransType w on w.WTransType_ID = p.Product_WalletsTransType
		where p.Product_BranchCode = @BranchCode
		AND p.Product_Status = 0
		AND pc.ProCategory_Code = @ProductCategory
		AND Product_ItemCode in (select ProductCounter_ProductCode from tblProductCounter WHERE ProductCounter_CounterID = @intCounterID)
		Order by Product_ItemCode
	END

	
END
