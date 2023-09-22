/****** Object:  Procedure [dbo].[sp_tblAddon_Group_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblAddon_Group_Update]
	-- Add the parameters for the stored procedure here
	@ID		int ,
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

	DECLARE @strCompanyCode nvarchar(50)
	select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUsercode

	Update tblAddon_Group set AddonGroup_Desc = @strDesc, AddonGroup_Status = @intStatus
	WHERE AddonGroup_ID = @ID
	
	Declare @strAddOnGroupCode nvarchar(50)
	select @strAddOnGroupCode = AddonGroup_Code from tblAddon_Group where AddonGroup_ID  = @ID

	delete from tblAddon_Set where AddOnSet_GroupCode = @strAddOnGroupCode

	DECLARE @tblSummary TABLE
	(AddOnItemID bigint, AddOnItemCode nvarchar(50), ISPROCCESS INT)

	insert into @tblSummary
	select [Name], '', 0 from  dbo.fnSplitstringToTable(@strAddOnItem) 

	Update @tblSummary set AddOnItemCode = A.Addon_ItemCode
	from @tblSummary S inner join tblAddon_Item A on S.AddOnItemID = A.Addon_ID

	INSERT INTO tblAddon_Set
	(AddOnSet_GroupCode, AddOnSet_ItemCode, AddOnSet_CreatedBy, AddOnSet_CreatedDate, AddOnSet_CompanyCode)
	select @strAddOnGroupCode, AddOnItemCode,@strUsercode,GETDATE(),@strCompanyCode from @tblSummary

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
