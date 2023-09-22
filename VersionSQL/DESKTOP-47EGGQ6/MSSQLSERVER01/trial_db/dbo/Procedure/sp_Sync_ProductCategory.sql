/****** Object:  Procedure [dbo].[sp_Sync_ProductCategory]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_ProductCategory]
	@strCompanyCode nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intID = 0
	BEGIN
		select ProCategory_ID, ProCategory_Code from tblProductCategory where ProCategory_Sync = 0 AND
		ProCategory_CompanyCode = @strCompanyCode
		
	END
	ELSE
	BEGIN
		Select * from tblProductCategory where ProCategory_Sync = 0
		AND ProCategory_CompanyCode = @strCompanyCode
		AND ProCategory_ID = @intID
	END
    
END
