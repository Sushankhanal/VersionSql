/****** Object:  Procedure [dbo].[sp_Sync_AddOnItem]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_AddOnItem]
	@strCompanyCode nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intID = 0
	BEGIN
		Select Addon_ID, Addon_ItemCode from tblAddon_Item where Addon_Sync = 0
		AND Addon_CompanyCode = @strCompanyCode
		--AND Product_ItemCode = 'ITEM0002'
	END
	ELSE
	BEGIN
		Select * from tblAddon_Item where Addon_Sync = 0
		AND Addon_CompanyCode = @strCompanyCode
		AND Addon_ID = @intID
	END
    
END
