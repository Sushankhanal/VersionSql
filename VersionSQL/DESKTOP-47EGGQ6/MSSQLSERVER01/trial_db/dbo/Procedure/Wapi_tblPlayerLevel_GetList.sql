/****** Object:  Procedure [dbo].[Wapi_tblPlayerLevel_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec Wapi_tblPlayerLevel_GetList '',-1,-1
CREATE PROCEDURE [dbo].[Wapi_tblPlayerLevel_GetList] (
	@strName	nvarchar(50),
	@intStatus			smallint = -1,
	@intPlayerLevelID	bigint = -1

) AS
BEGIN
	--Declare @strCompanyCode nvarchar(50)
	--select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

	select ROW_NUMBER() OVER(ORDER BY PlayerLevel_Sort)  AS RowNo, *, 
	(CASE PlayerLevel_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as PlayerLevel_StatusText
	from tblPlayerLevel (NOLOCK)
	where PlayerLevel_Name  LIKE '%' + @strName + '%' AND
	(CASE WHEN @intStatus = -1 THEN 1 ELSE CASE WHEN PlayerLevel_Status = @intStatus THEN 1 ELSE 0 END END) > 0
	AND (CASE WHEN @intPlayerLevelID = -1 THEN 1 ELSE CASE WHEN PlayerLevel_ID = @intPlayerLevelID THEN 1 ELSE 0 END END) > 0
	Order by PlayerLevel_Sort, PlayerLevel_Name
END
