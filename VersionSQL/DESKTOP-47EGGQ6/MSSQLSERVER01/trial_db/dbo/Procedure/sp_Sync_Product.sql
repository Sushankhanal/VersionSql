/****** Object:  Procedure [dbo].[sp_Sync_Product]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_Product]
	@strCompanyCode nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intID = 0
	BEGIN
		Select Product_ID, Product_ItemCode from tblProduct where Product_Sync = 0
		AND Product_CompanyCode = @strCompanyCode
		--AND Product_ItemCode = 'ITEM0002'
	END
	ELSE
	BEGIN
		Select * from tblProduct where Product_Sync = 0
		AND Product_CompanyCode = @strCompanyCode
		AND Product_ID = @intID
	END
    
END
