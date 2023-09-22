/****** Object:  Procedure [dbo].[api_GetProductList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory('')
--exec api_GetFoodCategory(''
--exec api_GetProductList '','comp02','',''
CREATE PROCEDURE [dbo].[api_GetProductList] (
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@strCategoryCode	nvarchar(50),
	@strOrderNo		nvarchar(50)
) AS
BEGIN
	Declare @strSeperator nvarchar(50) = '<>'

	if @strCategoryCode = ''
	BEGIN
		SELECT Product_ID, Product_ItemCode, Product_Desc,
		--(CASE CHARINDEX(@strSeperator, Product_Desc) WHEN 0 THEN Product_Desc ELSE SUBSTRING(Product_Desc,  0, CHARINDEX(@strSeperator, Product_Desc)) END) as Product_Desc,
		--(CASE CHARINDEX(@strSeperator, Product_Desc) WHEN 0 THEN Product_Desc ELSE REPLACE(SUBSTRING(Product_Desc, CHARINDEX(@strSeperator, Product_Desc), LEN(Product_Desc)),@strSeperator,'') END)  AS Product_Desc_Half, 
		Product_ChiDesc, 
		--(CASE Product_ChiDesc WHEN '' THEN Product_Desc ELSE (Product_ChiDesc + ' (' + Product_Desc + ')') END) as Product_FullDesc, 
		'Half' as UOM_Half, 'Full' as UOM_Full, 
		Product_UnitPrice as UnitPrice_Full, Product_UnitPrice2 as UnitPrice_Half,
		Product_CategoryCode as CategoryCode,PC.ProCategory_Name as CategoryName, 
		PC.ProCategory_ChiName as CategoryChiName, Product_TaxCode, Product_TaxRate,
		PC.ProCategory_Group, Product_Status, Product_ImgPath,
		(CASE ProCategory_ChiName WHEN '' THEN ProCategory_Name ELSE (ProCategory_ChiName + ' (' + ProCategory_Name + ')') END) as
		CategoryFullName,
		--Product_Desc2 as Product_Desc_Half, Product_ChiDesc2 as Product_ChiDesc_Half,
		Product_Desc as Product_Desc_Half, Product_ChiDesc as Product_ChiDesc_Half,
		Product_FullDesc ,Product_HalfDesc,
		Product_Remarks,Product_RemarksChi, Product_ImgExtra
		FROM            tblProduct P
		inner join tblProductCategory PC on P.Product_CategoryCode = PC.ProCategory_Code
		where Product_CompanyCode = @strCompanyCode
		AND Product_ItemCode <> 'HOTPOT'
		and Product_Status = 0
		--LIKE '%' + @strSerialNumber + '%'
		Order by Product_Desc
	END
	ELSE
	BEGIN
		SELECT Product_ID, Product_ItemCode, Product_Desc, Product_ChiDesc, 
		--(CASE Product_ChiDesc WHEN '' THEN Product_Desc ELSE (Product_ChiDesc + ' (' + Product_Desc + ')') END) as Product_FullDesc, 
		'Half' as UOM_Half, 'Full' as UOM_Full, 
		Product_UnitPrice as UnitPrice_Full, Product_UnitPrice2 as UnitPrice_Half,
		Product_CategoryCode as CategoryCode,PC.ProCategory_Name as CategoryName, 
		PC.ProCategory_ChiName as CategoryChiName, Product_TaxCode, Product_TaxRate,
		PC.ProCategory_Group, Product_Status, Product_ImgPath,
		(CASE ProCategory_ChiName WHEN '' THEN ProCategory_Name ELSE (ProCategory_ChiName + ' (' + ProCategory_Name + ')') END) as
		CategoryFullName,
		--Product_Desc2 as Product_Desc_Half, Product_ChiDesc2 as Product_ChiDesc_Half,
		Product_Desc as Product_Desc_Half, Product_ChiDesc as Product_ChiDesc_Half,
		Product_FullDesc ,Product_HalfDesc,
		Product_Remarks,Product_RemarksChi, Product_ImgExtra
		FROM            tblProduct P
		inner join tblProductCategory PC on P.Product_CategoryCode = PC.ProCategory_Code
		where Product_CompanyCode = @strCompanyCode
		AND Product_CategoryCode = @strCategoryCode
		AND Product_ItemCode <> 'HOTPOT'
		
		and Product_Status = 0
		Order by Product_Desc
	END
	
	
END
