/****** Object:  Procedure [dbo].[mobile_user_mobile_verification_resend]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_user_mobile_verification_resend]


	@mobileNo as nvarchar(50),
	@verificatonCode as nvarchar(50),
	@verificationKey as nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY  

		
		

		IF(SELECT COUNT(*)  FROM verification
		WHERE 
		DATEDIFF(SECOND,verification_createdon,GETDATE()) <= 1200 
		 AND verification_verify = 0
		 --AND verification_code = @verificatonCode 
		 AND verification_mobileno = @mobileNo 
		 AND verification_key = @verificationKey) < 1
		 BEGIN

			ROLLBACK TRANSACTION
			SELECT '-1' AS 'RETURN_RESULT'
			RETURN

		 END


		 SELECT COUNT(*) AS 'RETURN_RESULT'  FROM verification
		WHERE 
		DATEDIFF(SECOND,verification_createdon,GETDATE()) <= 1200 
		 AND verification_verify = 0
		 --AND verification_code = @verificatonCode 
		 AND verification_mobileno = @mobileNo 
		 AND verification_key = @verificationKey
		 AND DATEDIFF(SECOND,verification_createdon,GETDATE()) >= 60 

		COMMIT TRANSACTION
		SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  
		ROLLBACK TRANSACTION
		SELECT '-98' AS 'RETURN_RESULT'
	END CATCH

END
