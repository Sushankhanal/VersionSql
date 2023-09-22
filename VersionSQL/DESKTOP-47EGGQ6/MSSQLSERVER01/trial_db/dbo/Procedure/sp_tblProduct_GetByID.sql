/****** Object:  Procedure [dbo].[sp_tblProduct_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblProduct_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY Product_ItemCode)  AS RowNo,
				*, 
				(CASE Product_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Product_StatusText
				from tblProduct (NOLOCK)
				where Product_ID  = @intID

	Declare @strProductCode nvarchar(50)
	select @strProductCode = Product_ItemCode from tblProduct where Product_ID  = @intID

	select * from tblProductCounter where ProductCounter_ProductCode = @strProductCode
END
