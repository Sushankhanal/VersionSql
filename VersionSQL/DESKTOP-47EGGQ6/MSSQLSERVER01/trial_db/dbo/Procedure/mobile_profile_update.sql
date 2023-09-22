/****** Object:  Procedure [dbo].[mobile_profile_update]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_profile_update]


	@dob as date,
	@name as nvarchar(MAX),
	@gender as int,
	@user_id as bigint,
	@mobileNo as nvarchar(50),
	@session_key as nvarchar(2048)

AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY  
		
		
		IF
		(
		SELECT 
		COUNT(mUser_ID) 
		FROM tblUserMobile 
		WHERE mUser_MobileNo = @mobileNo AND mUser_ID = @user_id
		AND mUser_Status = 1
		AND
		(SELECT COUNT(*) FROM [session] WHERE session_key = @session_key AND session_user_id = @user_id AND session_expired = 0) > 0
		) 
		> 0 
		BEGIN
			 UPDATE tblUserMobile 

			 SET mUser_FullName = @name,
			 mUser_DOB = @dob,
			 mUser_Gender = @gender
			 WHERE mUser_MobileNo = @mobileNo AND mUser_Status = 1
		 
			 IF @@ROWCOUNT > 0
			 BEGIN
				COMMIT TRANSACTION
				SELECT 1 AS 'RETURN_RESULT'
			 END
			 ELSE 
			 BEGIN
				ROLLBACK TRANSACTION
				SELECT '-1' AS 'RETURN_RESULT'
			 END

		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			SELECT '-2' AS 'RETURN_RESULT'

		END

		SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  
		ROLLBACK TRANSACTION
		SELECT '-98' AS 'RETURN_RESULT'
	END CATCH

END
