/****** Object:  Procedure [dbo].[sp_tblBranch_Get]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblBranch_Get] (
	@strCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@intOption	int	-- 0: all, 1: with None
) AS
BEGIN
	if @intOption = 0
	BEGIN
		select B.Branch_Code, B.Branch_Name  from tblBranch B where B.Branch_Code LIKE '%' + @strCode + '%'
		AND Branch_CompanyCode = @strCompanyCode
		Order by B.Branch_Code
	END
	ELSE if @intOption = 1
	BEGIN
		select '' as Branch_Code, 'None' as Branch_Name
		Union
		select B.Branch_Code, B.Branch_Name  from tblBranch B where B.Branch_Code LIKE '%' + @strCode + '%'
		AND Branch_CompanyCode = @strCompanyCode
		Order by Branch_Code
	END
	
END
