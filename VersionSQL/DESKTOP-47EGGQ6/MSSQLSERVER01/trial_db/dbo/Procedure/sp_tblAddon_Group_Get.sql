/****** Object:  Procedure [dbo].[sp_tblAddon_Group_Get]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblAddon_Group_Get] (
	@strCode	nvarchar(50),
	@intOption	int,	-- 0: all, 1: with None
	@strUsercode	nvarchar(50)
) AS
BEGIN

	DECLARE @strCompanyCode nvarchar(50)
	select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUsercode

	if @intOption = 0
	BEGIN
		select G.AddonGroup_Code, G.AddonGroup_Desc  from tblAddon_Group G 
		where G.AddonGroup_Code = @strCode AND AddonGroup_CompanyCode = @strCompanyCode
		Order by G.AddonGroup_Code
	END
	ELSE if @intOption = 1
	BEGIN
		select '' as AddonGroup_Code, 'None' as AddonGroup_Desc
		Union
		select G.AddonGroup_Code, G.AddonGroup_Desc  from tblAddon_Group G where G.AddonGroup_Code LIKE '%' + @strCode + '%'
		AND AddonGroup_CompanyCode = @strCompanyCode
		Order by AddonGroup_Code
	END
	
END
