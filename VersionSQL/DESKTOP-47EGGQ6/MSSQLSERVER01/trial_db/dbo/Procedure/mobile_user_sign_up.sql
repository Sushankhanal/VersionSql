/****** Object:  Procedure [dbo].[mobile_user_sign_up]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_user_sign_up]

	@FirstName as nvarchar(50),
	@LastName as nvarchar(50),
	@mobileNo as nvarchar(50),
	@verificatonCode as nvarchar(50),
	@verificationKey as nvarchar(50),
	@password as nvarchar(MAX),
	@companyCode as nvarchar(50)

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
		 AND verification_type = 0

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

		 INSERT INTO tblUserMobile
		 (
		 mUser_LoginID,
		 mUser_Code, 
		 mUser_Password, 
		 mUser_FullName, 
		 mUser_MobileNo, 
		 mUser_TotalBalance, 
		 mUser_RegisterDate, 
		 mUser_Status, 
		 mUser_CompanyCode
		 )
		 SELECT 
		 @mobileNo,
		 @mobileNo, 
		 PWDENCRYPT(@password),
		 (@FirstName), -- + ' ' + @LastName), 
		 @mobileNo,
		 0,
		 GETDATE(),
		 1,
		 @companyCode
		 WHERE
		 (SELECT COUNT(*) FROM tblUserMobile WHERE mUser_MobileNo = @mobileNo) = 0
		 
			 IF @@ROWCOUNT > 0
			 BEGIN

				INSERT INTO 
				tblUserWallet(UWallet_UserCode,UWallet_Code,UWallet_Type, UWallet_Balance, UWallet_ModifiedDate)
				VALUES
				(@mobileNo,@mobileNo,1,0, GETDATE())

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


			--COMMIT TRANSACTION
			--SELECT 1 AS 'RETURN_RESULT'
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
