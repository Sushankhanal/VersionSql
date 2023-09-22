/****** Object:  Procedure [dbo].[sp_Sync_Counter]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_Counter]
	@strCompanyCode nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intID = 0
	BEGIN
		Select Counter_ID, Counter_Code from tblCounter where Counter_Sync = 0
		AND Counter_CompanyCode = @strCompanyCode
		--AND Product_ItemCode = 'ITEM0002'
	END
	ELSE
	BEGIN
		Select * from tblCounter where Counter_Sync = 0
		AND Counter_CompanyCode = @strCompanyCode
		AND Counter_ID = @intID

		select * from tblProductCounter where ProductCounter_CounterID = @intID

	END
    
END
