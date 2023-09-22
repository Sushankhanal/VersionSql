/****** Object:  Procedure [dbo].[Wapi_tblPOSUser_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblPOSUser_Add]
	-- Add the parameters for the stored procedure here
	@strName	nvarchar(50),
	@intStatus	smallint,
    @strCompanyCode	nvarchar(50) ='',
	@strUsercode	nvarchar(50),
	@strLoginID		nvarchar(50),
	@strPassword	nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @intID	bigint = 0
		Declare @strResultText nvarchar(255) = ''
		Declare @intResultCode int = 0
		
		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(POSUser_ID), 0) FROM tblPOSUser NOLOCK WHERE (POSUser_LoginID = @strLoginID )
		
		--set @intCount = 0
		IF @intCount = 0 
		BEGIN
			Declare @strPOSUserCode nvarchar(50) = ''
			set @strPOSUserCode = @strLoginID

			select top 1 @strCompanyCode = Company_Code from tblCompany c (NOLOCK) Order by Company_ID


			INSERT INTO tblPOSUser
			(POSUser_Code, POSUser_LoginID, POSUser_Password, POSUser_Status, POSUser_Name, 
			POSUser_CreatedBy, POSUser_CreatedDate, POSUser_UserType, POSUser_CompanyCode, POSUser_UserGroupID,
			POSUser_MinGiveOutDiscountAmt, POSUser_MinGiveOutDiscountRate)
			VALUES (
			@strPOSUserCode,@strLoginID, @strPassword, @intStatus, @strName, 
			@strUserCode, GETDATE(), 0, @strCompanyCode, 0, 0, 0)
			SELECT @intID = SCOPE_IDENTITY()
			set @intResultCode = @intID
			set @strResultText = 'Success'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT

		END
		ELSE
		BEGIN
			set @intID = -1
			set @strResultText = 'Login ID used by another use, Please try another Login ID.'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
