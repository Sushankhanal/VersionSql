/****** Object:  Procedure [dbo].[sp_Sync_tblUserMobile_insert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_tblUserMobile_insert]
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
	select @intCount = ISNULL(COUNT(mUser_ID), 0) from tblUserMobile where mUser_Code = @strCode
	AND mUser_CompanyCode = @strCompanyCode AND mUser_ID = @intID

	IF @intCount > 0 
	BEGIN
		--Delete from tblPOSUser where POSUser_Code = @strCode
		--AND POSUser_CompanyCode = @strCompanyCode AND POSUser_ID = @intID
		Declare @int int
	END
	ELSE
	BEGIN
		SET IDENTITY_INSERT tblUserMobile ON 
		INSERT INTO tblUserMobile
		(mUser_ID, mUser_Code, mUser_LoginID, mUser_Password, mUser_FullName, mUser_MobileNo, mUser_DOB, mUser_Gender, 
		mUser_Address1, mUser_Address2, mUser_City, mUser_Postcode, mUser_State, mUser_TotalBalance, 
        mUser_RegisterDate, mUser_Status, mUser_CompanyCode, mUser_Remarks, mUser_TotalPoint, mUser_randomCode)
		Select mUser_ID, mUser_Code, mUser_LoginID, '', mUser_FullName, mUser_MobileNo, mUser_DOB, mUser_Gender, 
		mUser_Address1, mUser_Address2, mUser_City, mUser_Postcode, mUser_State, mUser_TotalBalance, 
        mUser_RegisterDate, mUser_Status, mUser_CompanyCode, mUser_Remarks, mUser_TotalPoint, mUser_randomCode
		FROM OPENXML (@intDoc,  N'/NewDataSet/Table', 2)
		WITH (mUser_ID bigint, mUser_Code nvarchar(50), mUser_LoginID nvarchar(50),  
		mUser_FullName nvarchar(50), mUser_MobileNo nvarchar(50), mUser_DOB date, mUser_Gender smallint, 
		mUser_Address1 nvarchar(50), mUser_Address2 nvarchar(50), mUser_City nvarchar(50), mUser_Postcode nvarchar(50), 
		mUser_State int, mUser_TotalBalance money, 
        mUser_RegisterDate datetime, mUser_Status smallint, mUser_CompanyCode nvarchar(50), mUser_Remarks nvarchar(50), 
		mUser_TotalPoint money, mUser_randomCode  nvarchar(1024))
		SET IDENTITY_INSERT tblUserMobile OFF
	END

	

	set @ID = @intID

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
