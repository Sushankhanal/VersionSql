/****** Object:  Procedure [dbo].[sp_Sync_Card]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_Card]
	@strCompanyCode nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intID = 0
	BEGIN
		Select Card_ID, Card_SerialNo from tblCard where Card_Sync = 0
		AND Card_CompanyCode = @strCompanyCode
		--AND Product_ItemCode = 'ITEM0002'
	END
	ELSE
	BEGIN
		Select * from tblCard where Card_Sync = 0
		AND Card_CompanyCode = @strCompanyCode
		AND Card_ID = @intID
	END
    
END
