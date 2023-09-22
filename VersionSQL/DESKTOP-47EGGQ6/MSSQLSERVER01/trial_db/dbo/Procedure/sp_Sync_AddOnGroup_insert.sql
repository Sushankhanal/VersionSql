/****** Object:  Procedure [dbo].[sp_Sync_AddOnGroup_insert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_AddOnGroup_insert]
	@ID		int OUT,
	@Xml XML,
	@strCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION

	DECLARE @objXml XML, @intDoc INT
	
	SELECT @objXml = @Xml
	EXEC sp_xml_preparedocument @intDoc OUTPUT, @objXml

	DECLARE @intCount INT
	select @intCount = ISNULL(COUNT(AddonGroup_ID), 0) from tblAddon_Group where AddonGroup_Code = @strCode
	AND AddonGroup_CompanyCode = @strCompanyCode AND AddonGroup_ID = @intID

	IF @intCount > 0 
	BEGIN
		Delete from tblAddon_Group where AddonGroup_Code = @strCode
		AND AddonGroup_CompanyCode = @strCompanyCode AND AddonGroup_ID = @intID
	END
	
	SET IDENTITY_INSERT tblAddon_Group ON 

	INSERT INTO tblAddon_Group
	(AddonGroup_ID, AddonGroup_Code, AddonGroup_Desc, AddonGroup_Status, AddonGroup_CreatedBy, AddonGroup_CreatedDate, AddonGroup_CompanyCode)
	Select AddonGroup_ID, AddonGroup_Code, AddonGroup_Desc, AddonGroup_Status, AddonGroup_CreatedBy, AddonGroup_CreatedDate, AddonGroup_CompanyCode
	FROM OPENXML (@intDoc,  N'/NewDataSet/Table', 2)
	WITH (AddonGroup_ID bigint, AddonGroup_Code nvarchar(50), AddonGroup_Desc nvarchar(255), AddonGroup_Status smallint, 
	AddonGroup_CreatedBy nvarchar(50), AddonGroup_CreatedDate datetime, AddonGroup_CompanyCode  nvarchar(50))

	SET IDENTITY_INSERT tblAddon_Group OFF

	SET IDENTITY_INSERT tblAddon_Set ON 
	INSERT INTO tblAddon_Set
	(AddOnSet_ID, AddOnSet_GroupCode, AddOnSet_ItemCode, AddOnSet_CreatedBy, AddOnSet_CreatedDate, AddOnSet_CompanyCode )
	Select AddOnSet_ID, AddOnSet_GroupCode, AddOnSet_ItemCode, AddOnSet_CreatedBy, AddOnSet_CreatedDate, AddOnSet_CompanyCode
	FROM OPENXML (@intDoc,  N'/NewDataSet/Table1', 2)
	WITH (AddOnSet_ID bigint, AddOnSet_GroupCode nvarchar(50),AddOnSet_ItemCode nvarchar(50),  
	AddOnSet_CreatedBy  nvarchar(50), AddOnSet_CreatedDate datetime, AddOnSet_CompanyCode nvarchar(50))

	SET IDENTITY_INSERT tblAddon_Set OFF

	set @ID = @intID

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
