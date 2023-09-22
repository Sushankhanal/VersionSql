/****** Object:  Procedure [dbo].[sp_tblUserMobile_Login]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblUserMobile_Login]
	@strLoginID		nvarchar(50),
	@strPassword	nvarchar(50),
	@strOutput		nvarchar(255) out
AS
BEGIN
	BEGIN
	BEGIN TRY
	
	BEGIN TRANSACTION
	SET NOCOUNT ON
		
		SELECT * FROM tblUserMobile (NOLOCK) WHERE mUser_LoginID = @strLoginID AND mUser_Password = @strPassword 
		AND mUser_Status = 0


	COMMIT TRANSACTION
	SET NOCOUNT OFF

	END TRY  

	BEGIN CATCH  
		ROLLBACK TRANSACTION
		SELECT @strOutput = ERROR_MESSAGE()
	END CATCH

END
END
