/****** Object:  Procedure [dbo].[sp_Sync_AddOnItem_insert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_AddOnItem_insert]
	@ID		int OUT,
	@Xml XML,
	@strItemCode	nvarchar(50),
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
	--print convert(nvarchar(max),@objXml)
	EXEC sp_xml_preparedocument @intDoc OUTPUT, @objXml

	DECLARE @intCount INT
	select @intCount = ISNULL(COUNT(Addon_ID), 0) from tblAddon_Item where Addon_ItemCode = @strItemCode
	AND Addon_CompanyCode = @strCompanyCode AND Addon_ID = @intID

	IF @intCount > 0 
	BEGIN
		Delete from tblAddon_Item  where Addon_ItemCode = @strItemCode
		AND Addon_CompanyCode = @strCompanyCode AND Addon_ID = @intID
	END
	
	SET IDENTITY_INSERT tblAddon_Item ON 

	INSERT INTO tblAddon_Item
	(Addon_ID, Addon_ItemCode, Addon_Desc, Addon_UnitPrice, Addon_Status, Addon_CreatedBy, Addon_CreatedDate, Addon_CompanyCode)
	Select Addon_ID, Addon_ItemCode, Addon_Desc, Addon_UnitPrice, Addon_Status, Addon_CreatedBy, Addon_CreatedDate, Addon_CompanyCode
	FROM OPENXML (@intDoc,  N'/NewDataSet/Table', 2)
	WITH (Addon_ID bigint, Addon_ItemCode nvarchar(50), Addon_Desc nvarchar(255),  
	Addon_UnitPrice money, Addon_Status smallint, 
	Addon_CreatedBy nvarchar(50), Addon_CreatedDate datetime, Addon_CompanyCode nvarchar(50))
	SET IDENTITY_INSERT tblAddon_Item OFF

	set @ID = @intID

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
