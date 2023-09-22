/****** Object:  Procedure [dbo].[mobile_user_mobile_verification_pre]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_user_mobile_verification_pre]


	@mobileNo as nvarchar(50),
	@verificatonCode as nvarchar(50),
	@verificationKey as nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY  


		

		SELECT COUNT(*) AS 'RETURN_RESULT' FROM verification
		WHERE 
		DATEDIFF(SECOND,verification_createdon,GETDATE()) <= 1200 
		 AND verification_verify = 0
		 AND verification_code = @verificatonCode 
		 AND verification_mobileno = @mobileNo 
		 AND verification_key = @verificationKey

		COMMIT TRANSACTION
		SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  
		ROLLBACK TRANSACTION
		SELECT '-98' AS 'RETURN_RESULT'
	END CATCH

END
