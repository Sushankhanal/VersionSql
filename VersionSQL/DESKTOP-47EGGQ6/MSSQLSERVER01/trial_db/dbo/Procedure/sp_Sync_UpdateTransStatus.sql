/****** Object:  Procedure [dbo].[sp_Sync_UpdateTransStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_UpdateTransStatus]	
	@strTransCode	nvarchar(50),
	@intStatus		int,
	@strTransType	nvarchar(50),
	@strCompanyCode nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	if @strTransType = 'Local Payment'
	BEGIN
		Update tblPayment_Header set Payment_Sync = 1, Payment_SyncDate = GETDATE()
		where Payment_ID = @intID
	END
	if @strTransType = 'Settlement'
	BEGIN
		Update tblSettlement set Settlement_Sync = 1, Settlement_SyncDate = GETDATE()
		where Settlement_ID = @intID
	END
	
END
