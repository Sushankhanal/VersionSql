/****** Object:  Procedure [dbo].[sp_tblUserMobile_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblUserMobile_Add]
	-- Add the parameters for the stored procedure here
	@strUserCode	nvarchar(50) OUT,
	@strLoginID		nvarchar(50),
	@strPassword	nvarchar(50),
	@strFullName	nvarchar(50),
	@strMobileNo	nvarchar(50),
	@dtDOB			Date, -- yyyy-MM-dd
	@intGender	 	smallint, 
    @strAddress1	nvarchar(50),
	@strAddress2	nvarchar(50),
	@strCity		nvarchar(50),
	@strPostcode	nvarchar(50),
	@intState		int,
	@strCompanyCode	nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @intCount INT
		DECLARE @ID INT
		SELECT @intCount = ISNULL(COUNT(mUser_ID), 0) FROM tblUserMobile NOLOCK 
		WHERE (mUser_LoginID = @strLoginID )

		IF @intCount = 0 
		BEGIN
			DECLARE @PrefixType VARCHAR(50), @intRowCount INT
			set @PrefixType = 'MobileUser'
			EXEC sp_tblPrefixNumber_GetNextRunNumber 'MobileUser', @PrefixType, 0, @strUserCode OUTPUT

			INSERT INTO tblUserMobile
			(mUser_Code, mUser_LoginID, mUser_Password, mUser_FullName, mUser_MobileNo, mUser_DOB, 
			mUser_Gender, mUser_Address1, mUser_Address2, mUser_City, mUser_Postcode, mUser_State, mUser_TotalBalance, 
			mUser_RegisterDate, mUser_Status, mUser_CompanyCode)
			VALUES (
			@strUserCode,@strLoginID,@strPassword,@strFullName,@strMobileNo,@dtDOB,
			@intGender,@strAddress1,@strAddress2,@strCity,@strPostcode,@intState,0,GETDATE(),1,@strCompanyCode)
			SELECT @ID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			RAISERROR ('Login ID already used by another user. Please try another login id.',16,1);  
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
