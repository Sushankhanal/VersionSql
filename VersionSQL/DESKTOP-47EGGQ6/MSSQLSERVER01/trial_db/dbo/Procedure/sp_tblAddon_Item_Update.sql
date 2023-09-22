/****** Object:  Procedure [dbo].[sp_tblAddon_Item_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblAddon_Item_Update]
	-- Add the parameters for the stored procedure here
	@ID		int ,
	@strItemName	nvarchar(100),
	@dblUnitPrice	money,
	@intStatus			smallint,
	@dblUnitCost		money,
	@strUsercode		nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Declare @strItemCode nvarchar(50)

		Update tblAddon_Item set 
		Addon_Desc = @strItemName, Addon_UnitPrice = @dblUnitPrice, Addon_Status = @intStatus, 
		Addon_Cost = @dblUnitCost
		where Addon_ID = @ID
		

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
