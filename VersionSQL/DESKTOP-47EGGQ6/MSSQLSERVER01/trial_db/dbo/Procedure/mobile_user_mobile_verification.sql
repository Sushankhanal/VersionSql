/****** Object:  Procedure [dbo].[mobile_user_mobile_verification]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_user_mobile_verification]


	@mobileNo as nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY  


		DECLARE @random_number nvarchar(50), @random_key nvarchar(1024)
	
		SELECT @random_key = cast((Abs(Checksum(NewId()))%10) as varchar(1)) + char(ascii('a')+(Abs(Checksum(NewId()))%25)) + char(ascii('A')+(Abs(Checksum(NewId()))%25)) + left(newid(),500) 
		SELECT @random_number = cast((900000* Rand() + 100000) as int )
		PRINT @random_key
		PRINT @random_number

		INSERT INTO verification
		(
		verification_code,
		verification_createdon,
		verification_mobileno,
		verification_key
		)
		SELECT 
		@random_number,
		GETDATE(),
		@mobileNo,
		@random_key
		WHERE
		(SELECT COUNT(*) FROM tblUserMobile WHERE mUser_MobileNo = @mobileNo) = 0


		 
		 
		 IF @@ROWCOUNT > 0
		 BEGIN
			COMMIT TRANSACTION
			SELECT 000000 as verification_code, @random_key as verification_key, @mobileNo as mobile_no, '1' AS 'RETURN_RESULT'
		 END
		 ELSE 
		 BEGIN
			ROLLBACK TRANSACTION
			SELECT '-1' AS 'RETURN_RESULT' -- mobile no not available
		 END

		SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  
		ROLLBACK TRANSACTION
		SELECT '-98' AS 'RETURN_RESULT'
	END CATCH

END
