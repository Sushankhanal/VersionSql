/****** Object:  Procedure [dbo].[api_GetFoodCategory]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory('')
--exec api_GetFoodCategory(''

CREATE PROCEDURE [dbo].[api_GetFoodCategory] (
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50)
) AS
BEGIN

	SELECT ProCategory_ID, ProCategory_Code, ProCategory_Name, ProCategory_ChiName, ProCategory_Status, 
	ProCategory_CompanyCode, ProCategory_Order, ProCategory_ImgPath, ProCategory_Desc
	FROM	tblProductCategory
	WHERE	(ProCategory_Group = 2)
	AND ProCategory_CompanyCode = @strCompanyCode
	Order by ProCategory_Order
END
