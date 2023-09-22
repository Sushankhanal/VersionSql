/****** Object:  Procedure [dbo].[api_GetSoupCategory]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory '','comp02'
--exec api_GetFoodCategory ''

CREATE PROCEDURE [dbo].[api_GetSoupCategory] (
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50)
) AS
BEGIN
	
	--Declare @intCount int = 0
	--SELECT @intCount = COUNT(ProCategory_ID)
	--FROM	tblProductCategory
	--WHERE	(ProCategory_Group = 1)
	--AND ProCategory_CompanyCode = @strCompanyCode

	--INSERT INTO tblA
	--(strValue, CreatedDate)
	--VALUES
	--(@intCount,getdate())

	SELECT ProCategory_ID, ProCategory_Code, ProCategory_Name, ProCategory_ChiName, ProCategory_Status, 
	ProCategory_CompanyCode, ProCategory_Order, ProCategory_ImgPath, ProCategory_Desc
	FROM	tblProductCategory
	WHERE	(ProCategory_Group = 1)
	AND ProCategory_CompanyCode = @strCompanyCode
	Order by ProCategory_Order
END
