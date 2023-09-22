/****** Object:  Procedure [dbo].[sp_Sync_AddOnGroup]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_AddOnGroup]
	@strCompanyCode nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intID = 0
	BEGIN
		Select AddonGroup_ID, AddonGroup_Code from tblAddon_Group where AddonGroup_Sync = 0
		AND AddonGroup_CompanyCode = @strCompanyCode
		--AND Product_ItemCode = 'ITEM0002'
	END
	ELSE
	BEGIN
		Select * from tblAddon_Group where AddonGroup_Sync = 0
		AND AddonGroup_CompanyCode = @strCompanyCode
		AND AddonGroup_ID = @intID

		Declare @strGroupCode nvarchar(50) = ''
		Select @strGroupCode = AddonGroup_Code from tblAddon_Group where AddonGroup_Sync = 0
		AND AddonGroup_CompanyCode = @strCompanyCode
		AND AddonGroup_ID = @intID

		select * from tblAddon_Set where AddOnSet_GroupCode = @strGroupCode

	END
    
END
