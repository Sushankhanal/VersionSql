/****** Object:  Procedure [dbo].[mobile_get_user_email]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_get_user_email]


	@user_id as bigint,
	@mobileNo as nvarchar(50),
	@session_key as nvarchar(2048)


AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY  

		SELECT *
		  FROM email
		  WHERE email_user_id = @user_id AND email_deleted = 0
		AND
		(SELECT COUNT(*) FROM [session] WHERE session_key = @session_key AND session_user_id = @user_id) > 0
		AND 
		(SELECT COUNT(*) FROM tblUserMobile WHERE mUser_ID = @user_id AND mUser_Code = @mobileNo) > 0
		
		COMMIT TRANSACTION
		SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  
		ROLLBACK TRANSACTION
		SELECT '-98' AS 'RETURN_RESULT'
	END CATCH

END
