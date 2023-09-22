/****** Object:  Procedure [dbo].[Wapi_tblProduct_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Wapi_tblProduct_GetList] (
	@intProductID	bigint = -1
) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY Product_ItemCode)  AS RowNo,
				Product_ID, Product_ItemCode, Product_Desc,Product_UOM,Product_UnitPrice,Product_Status,Product_CreatedBy, 
				Product_CreatedDate, Product_Cost,Product_CategoryCode, C.ProCategory_Desc as Product_CategoryName, Product_TaxRate,
				Product_UpdatedBy,Product_UpdatedDate,Product_ImgPath,
				(CASE Product_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Product_StatusText
				from tblProduct P (NOLOCK)
				inner join tblProductCategory C (NOLOCK) on P.Product_CategoryCode = C.ProCategory_Code
				where (CASE WHEN @intProductID = -1 THEN 1 ELSE CASE WHEN Product_ID = @intProductID THEN 1 ELSE 0 END END) > 0

END
