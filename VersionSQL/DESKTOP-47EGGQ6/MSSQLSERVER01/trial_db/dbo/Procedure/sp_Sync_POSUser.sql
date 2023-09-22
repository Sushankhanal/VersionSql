/****** Object:  Procedure [dbo].[sp_Sync_POSUser]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_POSUser]
	@strCompanyCode nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intID = 0
	BEGIN
		Select POSUser_ID, POSUser_Code from tblPOSUser where POSUser_Sync = 0
		AND POSUser_CompanyCode = @strCompanyCode
		--AND Product_ItemCode = 'ITEM0002'
	END
	ELSE
	BEGIN
		Select * from tblPOSUser where POSUser_Sync = 0
		AND POSUser_CompanyCode = @strCompanyCode
		AND POSUser_ID = @intID
	END
    
END
