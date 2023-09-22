/****** Object:  Procedure [dbo].[sp_Sync_Branch]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_Branch]
	@strCompanyCode nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intID = 0
	BEGIN
		Select Branch_ID, Branch_Code from tblBranch where Branch_Sync = 0
		AND Branch_CompanyCode = @strCompanyCode
		--AND Product_ItemCode = 'ITEM0002'
	END
	ELSE
	BEGIN
		Select * from tblBranch where Branch_Sync = 0
		AND Branch_CompanyCode = @strCompanyCode
		AND Branch_ID = @intID
	END
    
END
