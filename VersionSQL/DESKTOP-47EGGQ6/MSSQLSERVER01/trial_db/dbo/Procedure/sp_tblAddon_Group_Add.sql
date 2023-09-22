/****** Object:  Procedure [dbo].[sp_tblAddon_Group_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblAddon_Group_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strDesc	nvarchar(255),
	@intStatus			smallint,
	@strAddOnItem		nvarchar(1000),
	@strUsercode		nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Declare @strCode nvarchar(50)

		DECLARE @PrefixType VARCHAR(50), @intRowCount INT
		set @PrefixType = 'AddonGroup'
		EXEC sp_tblPrefixNumber_GetNextRunNumber 'Addon', @PrefixType, 0, @strCode OUTPUT

		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(AddonGroup_ID), 0) FROM tblAddon_Group NOLOCK 
		WHERE (AddonGroup_Code = @strCode )

		IF @intCount = 0 
		BEGIN
			DECLARE @strCompanyCode nvarchar(50)
			select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUsercode

			INSERT INTO tblAddon_Group
			(AddonGroup_Code, AddonGroup_Desc, AddonGroup_Status, AddonGroup_CreatedBy, 
			AddonGroup_CreatedDate, AddonGroup_CompanyCode)
			VALUES (
			@strCode,@strDesc,@intStatus,@strUsercode,GETDATE(),@strCompanyCode)
			SELECT @ID = SCOPE_IDENTITY()

			DECLARE @tblSummary TABLE
			(AddOnItemID bigint, AddOnItemCode nvarchar(50), ISPROCCESS INT)

			insert into @tblSummary
			select [Name], '', 0 from  dbo.fnSplitstringToTable(@strAddOnItem) 

			Update @tblSummary set AddOnItemCode = A.Addon_ItemCode
			from @tblSummary S inner join tblAddon_Item A on S.AddOnItemID = A.Addon_ID

			INSERT INTO tblAddon_Set
			(AddOnSet_GroupCode, AddOnSet_ItemCode, AddOnSet_CreatedBy, AddOnSet_CreatedDate, AddOnSet_CompanyCode)
			select @strCode, AddOnItemCode,@strUsercode,GETDATE(),@strCompanyCode from @tblSummary
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
