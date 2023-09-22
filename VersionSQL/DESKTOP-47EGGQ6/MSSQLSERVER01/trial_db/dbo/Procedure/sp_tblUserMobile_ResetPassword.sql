/****** Object:  Procedure [dbo].[sp_tblUserMobile_ResetPassword]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblUserMobile_ResetPassword] (
@strUserCode		nvarchar(50),
@strCurrentPassword	nvarchar(50),
@strNewPassword		nvarchar(50),
@strModifiedby		nvarchar(50),
@strCompanyCode		nvarchar(50)
) AS

	BEGIN TRANSACTION

	SET NOCOUNT ON
	
	DECLARE @intCount INT
	SELECT @intCount = ISNULL(COUNT(mUser_ID), 0) FROM [tblUserMobile] NOLOCK 
	WHERE mUser_Password = @strCurrentPassword and mUser_CompanyCode = @strCompanyCode and mUser_Code = @strUserCode
		
	IF @intCount = 0 
	BEGIN
		RAISERROR ('Invalid Old Password.',16,1);  
		COMMIT TRANSACTION
		SET NOCOUNT OFF
		RETURN (-1)
	END
	ELSE
	BEGIN
		UPDATE tblUserMobile SET
		mUser_Password = @strNewPassword
		WHERE mUser_Code = @strUserCode
	END
	
	
	
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
