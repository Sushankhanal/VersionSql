/****** Object:  Procedure [dbo].[sp_Sync_tblPOSUser_insert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_tblPOSUser_insert]
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
	--print convert(nvarchar(max),@objXml)
	EXEC sp_xml_preparedocument @intDoc OUTPUT, @objXml

	DECLARE @intCount INT
	select @intCount = ISNULL(COUNT(POSUser_ID), 0) from tblPOSUser where POSUser_Code = @strCode
	AND POSUser_CompanyCode = @strCompanyCode AND POSUser_ID = @intID

	IF @intCount > 0 
	BEGIN
		Delete from tblPOSUser where POSUser_Code = @strCode
		AND POSUser_CompanyCode = @strCompanyCode AND POSUser_ID = @intID
	END
	
	SET IDENTITY_INSERT tblPOSUser ON 
	INSERT INTO tblPOSUser
	(POSUser_ID, POSUser_Code, POSUser_LoginID, POSUser_Password, POSUser_Status, POSUser_Name, POSUser_CreatedBy, POSUser_CreatedDate, POSUser_UserType, POSUser_CompanyCode)
	Select POSUser_ID, POSUser_Code, POSUser_LoginID, POSUser_Password, POSUser_Status, POSUser_Name, POSUser_CreatedBy, POSUser_CreatedDate, POSUser_UserType, POSUser_CompanyCode
	FROM OPENXML (@intDoc,  N'/NewDataSet/Table', 2)
	WITH (POSUser_ID bigint, POSUser_Code nvarchar(50), POSUser_LoginID nvarchar(50), POSUser_Password nvarchar(50), POSUser_Status smallint, 
	POSUser_Name nvarchar(50), POSUser_CreatedBy nvarchar(50), POSUser_CreatedDate datetime, POSUser_UserType smallint,
	POSUser_CompanyCode nvarchar(50))
	SET IDENTITY_INSERT tblPOSUser OFF

	set @ID = @intID

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
