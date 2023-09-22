/****** Object:  Procedure [dbo].[Local_mobile_email_add]    Committed by VersionSQL https://www.versionsql.com ******/

create PROCEDURE [dbo].[Local_mobile_email_add]

	@email As nvarchar(50),
	@user_id as bigint,
	@mobileNo as nvarchar(50),
	@session_key as nvarchar(2048)

AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY  


	

		/****** Script for SelectTopNRows command from SSMS  ******/
		INSERT INTO email
		(
		email_createdon,
		email_email,
		email_user_id
		)
		SELECT 
		GETDATE(),
		@email,
		@user_id
		 WHERE
		 (SELECT COUNT(*) FROM email WHERE email_email = @email AND email_deleted = 0) = 0
		AND
		(SELECT COUNT(*) FROM [session] WHERE session_key = @session_key AND session_user_id = @user_id) > 0
		AND 
		(SELECT COUNT(*) FROM tblUserMobile WHERE mUser_ID = @user_id AND mUser_Code = @mobileNo) > 0
		
		 IF @@ROWCOUNT > 0
				BEGIN



				
				


				COMMIT TRANSACTION
				SELECT 1 AS 'RETURN_RESULT'
				SELECT	*
			  FROM email
			  WHERE email_user_id = @user_id AND email_deleted = 0
			AND
			(SELECT COUNT(*) FROM [session] WHERE session_key = @session_key AND session_user_id = @user_id) > 0
			AND 
			(SELECT COUNT(*) FROM tblUserMobile WHERE mUser_ID = @user_id AND mUser_Code = @mobileNo) > 0
			 END
			 ELSE 
			 BEGIN
				ROLLBACK TRANSACTION
				SELECT '-1' AS 'RETURN_RESULT'
			 END
		SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  
		ROLLBACK TRANSACTION
		SELECT '-98' AS 'RETURN_RESULT'
	END CATCH

END
