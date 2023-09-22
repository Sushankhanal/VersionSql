/****** Object:  Procedure [dbo].[mobile_user_mobile_verification_forgot_password_change]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_user_mobile_verification_forgot_password_change]


	@mobileNo as nvarchar(50),
	@verificatonCode as nvarchar(50),
	@verificationKey as nvarchar(50),
	@password as nvarchar(MAX)

AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY  


		UPDATE verification SET verification_verify = 1, verification_verifiedon = GETDATE()
		 WHERE 
		 DATEDIFF(SECOND,verification_createdon,GETDATE()) <= 1200
		 AND verification_verify = 0
		 AND verification_code = @verificatonCode 
		 AND verification_mobileno = @mobileNo 
		 AND verification_key = @verificationKey
		 AND verification_type = 1

		 IF @@ROWCOUNT > 0
		 PRINT 'SUCCESS'
		 ELSE
		 BEGIN
			ROLLBACK TRANSACTION
			SELECT '-2' AS 'RETURN_RESULT' --verification error
			RETURN
		 END


		 DECLARE @PrefixType VARCHAR(50), @intRowCount INT, @strUserCode nvarchar(50)
		 set @PrefixType = 'MobileUser'
		 EXEC sp_tblPrefixNumber_GetNextRunNumber 'MobileUser', @PrefixType, 0, @strUserCode OUTPUT

		 UPDATE tblUserMobile 
		 SET mUser_Password = PWDENCRYPT(@password)
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

		SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  
		ROLLBACK TRANSACTION
		SELECT '-98' AS 'RETURN_RESULT'
	END CATCH

END
