/****** Object:  Procedure [dbo].[sp_tblPOSUser_UpdatePassword]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblPOSUser_UpdatePassword]
	-- Add the parameters for the stored procedure here
	@ID				int ,
	@strOldPassword nvarchar(50),
	@strNewPassword	nvarchar(50),
	@strUsercode	nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @intCount INT
	SELECT @intCount = ISNULL(COUNT(POSUser_ID), 0) FROM tblPOSUser NOLOCK 
	WHERE (POSUser_Password = @strOldPassword ) AND (POSUser_ID = @ID )

	IF @intCount = 1
	BEGIN
		Update tblPOSUser Set
		POSUser_Password = @strNewPassword
		WHERE POSUser_ID = @ID
	END
	ELSE
	BEGIN
		RAISERROR ('Error: Old password is wrong. Please try again.',16,1);  
		COMMIT TRANSACTION
		SET NOCOUNT OFF
		RETURN (-1)
	END

		
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
