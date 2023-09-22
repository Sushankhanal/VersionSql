/****** Object:  Procedure [dbo].[sp_tblProductCategory_get]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblProductCategory_get] (
	@CounterCode	nvarchar(50),
	@CompanyCode	nvarchar(50)
) AS
BEGIN
	
	Declare @intCounterID int = 0
	select @intCounterID = Counter_ID from tblCounter where Counter_Code = @CounterCode and Counter_CompanyCode = @CompanyCode

	select pc.ProCategory_Order, pc.ProCategory_Code, pc.ProCategory_Name from tblProduct p
	inner join tblProductCategory pc on p.Product_CategoryCode = pc.ProCategory_Code
	where 
	p.Product_ItemCode in (select ProductCounter_ProductCode from tblProductCounter where ProductCounter_CounterID = @intCounterID)
	Group by pc.ProCategory_Order, pc.ProCategory_Code, pc.ProCategory_Name
	order by pc.ProCategory_Order, pc.ProCategory_Code

END
