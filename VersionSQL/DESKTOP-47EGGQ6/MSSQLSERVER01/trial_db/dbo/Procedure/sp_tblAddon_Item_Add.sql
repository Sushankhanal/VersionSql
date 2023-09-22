/****** Object:  Procedure [dbo].[sp_tblAddon_Item_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblAddon_Item_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
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

		DECLARE @PrefixType VARCHAR(50), @intRowCount INT
		set @PrefixType = 'Addon'
		EXEC sp_tblPrefixNumber_GetNextRunNumber 'Addon', @PrefixType, 0, @strItemCode OUTPUT

		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(Addon_ID), 0) FROM tblAddon_Item NOLOCK 
		WHERE (Addon_ItemCode = @strItemCode )

		IF @intCount = 0 
		BEGIN
			

			DECLARE @strCompanyCode nvarchar(50)
			select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUsercode

			INSERT INTO tblAddon_Item
			(Addon_ItemCode, Addon_Desc, Addon_UnitPrice, Addon_Status, 
			Addon_CreatedBy, Addon_CreatedDate, Addon_Cost, Addon_CompanyCode)
			VALUES (
			@strItemCode,@strItemName,@dblUnitPrice,@intStatus,
			@strUsercode,GETDATE(),@dblUnitCost,@strCompanyCode)
			SELECT @ID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			RAISERROR ('Error',16,1);  
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-1)
		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
