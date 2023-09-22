/****** Object:  Procedure [dbo].[api_GetCategory_All]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory('')
--exec api_GetFoodCategory(''
-- exec api_GetCategory_All '','comp02'
CREATE PROCEDURE [dbo].[api_GetCategory_All] (
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50)
) AS
BEGIN

	SELECT ProCategory_Order, ProCategory_Code,
	(CASE ProCategory_ChiName WHEN '' THEN ProCategory_Name ELSE (ProCategory_ChiName + ' (' + ProCategory_Name + ')') END) as ProCategory_Name
	FROM	tblProductCategory
	WHERE	ProCategory_CompanyCode = @strCompanyCode
	AND ProCategory_Status = 0
	
END
