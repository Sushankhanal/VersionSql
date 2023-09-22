/****** Object:  Procedure [dbo].[api_GetBeverageCategory]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory('')
--exec api_GetBeverageCategory '','comp02'

CREATE PROCEDURE [dbo].[api_GetBeverageCategory] (
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50)
) AS
BEGIN

	SELECT ProCategory_ID, ProCategory_Code, ProCategory_Name, ProCategory_ChiName, ProCategory_Status, 
	ProCategory_CompanyCode, ProCategory_Order, ProCategory_ImgPath, ProCategory_Desc
	FROM	tblProductCategory
	WHERE	(ProCategory_Group = 3)
	AND ProCategory_CompanyCode = @strCompanyCode
	Order by ProCategory_Order
END
