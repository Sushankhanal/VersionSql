/****** Object:  Procedure [dbo].[Local_mobile_card_add]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Local_mobile_card_add]

	@cardSerialNo As nvarchar(50),
	@user_id as bigint,
	@mobileNo as nvarchar(50),
	@session_key as nvarchar(2048),
	@CardId             bigint = NULL OUTPUT

AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY  


		DECLARE @result_int Int = 20

		--execute @result_int = sp_tblCardTrans_TransferOut @cardSerialNo, @mobileNo 

		--		IF @result_int <> 0
		--		BEGIN
		--			ROLLBACK TRANSACTION
		--			SELECT -1 AS 'RETURN_RESULT'
		--			RETURN
		--		END


		/****** Script for SelectTopNRows command from SSMS  ******/
		UPDATE [POSv2].[dbo].[tblCard] SET [Card_MobileUser] = @mobileNo, [Card_Status] = 0
		
		 WHERE [Card_SerialNo] = @cardSerialNo AND [Card_Status] = 0
		AND
		(SELECT COUNT(*) FROM [session] WHERE session_key = @session_key AND session_user_id = @user_id) > 0
		AND 
		(SELECT COUNT(*) FROM tblUserMobile WHERE mUser_ID = @user_id AND mUser_Code = @mobileNo) > 0
		
		-- Added by ricky
		UPDATE tblCard SET Card_Sync = 0 WHERE Card_SerialNo = @cardSerialNo 
		-- END Added by ricky
		set @CardId=@cardSerialNo
		 IF @@ROWCOUNT > 0
				BEGIN

				COMMIT TRANSACTION
				SELECT 1 AS 'RETURN_RESULT'
					SELECT [Card_ID]
				  ,[Card_SerialNo]
				  ,[Card_Status]
				  ,[Card_MobileUser]
				  ,[Card_CreatedBy]
				  ,[Card_CreatedDate]
			  FROM [POSv2].[dbo].[tblCard]
			  WHERE Card_MobileUser = @mobileNo
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
