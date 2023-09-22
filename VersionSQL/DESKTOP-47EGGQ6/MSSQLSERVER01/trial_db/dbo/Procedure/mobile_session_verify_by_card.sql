/****** Object:  Procedure [dbo].[mobile_session_verify_by_card]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_session_verify_by_card]

	@cardSerialNo As nvarchar(50),
	@session_key As nvarchar(2048)

AS
BEGIN
	
	BEGIN TRY  


		

		SELECT COUNT(Card_ID) AS RETURN_RESULT FROM tblCard 
		JOIN tblUserMobile ON tblUserMobile.mUser_LoginID = Card_MobileUser
		JOIN [session] ON session_user_id = tblUserMobile.mUser_ID
		WHERE [session].session_expired = 0
		AND Card_SerialNo = @cardSerialNo 
		AND session_key = @session_key
		AND Card_Status = 0



		SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  
		
		SELECT '-98' AS 'RETURN_RESULT'
	END CATCH

END
