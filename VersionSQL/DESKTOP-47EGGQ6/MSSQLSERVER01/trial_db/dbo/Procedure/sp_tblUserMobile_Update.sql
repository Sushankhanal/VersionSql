/****** Object:  Procedure [dbo].[sp_tblUserMobile_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblUserMobile_Update]
	-- Add the parameters for the stored procedure here
	@strUserCode	nvarchar(50),
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
		WHERE (mUser_Code = @strUserCode )

		IF @intCount = 0 
		BEGIN
			RAISERROR ('Fail to update user profile, please try again.',16,1);  
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-1)
		END
		ELSE
		BEGIN
			UPDATE tblUserMobile
			SET
			mUser_FullName = @strFullName, mUser_MobileNo = @strMobileNo, mUser_DOB = @dtDOB, mUser_Gender = @intGender, 
			mUser_Address1 = @strAddress1, mUser_Address2 = @strAddress2, mUser_City = @strCity, mUser_Postcode = @strPostcode, 
			mUser_State = @intState
			WHERE mUser_Code = @strUserCode
		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
