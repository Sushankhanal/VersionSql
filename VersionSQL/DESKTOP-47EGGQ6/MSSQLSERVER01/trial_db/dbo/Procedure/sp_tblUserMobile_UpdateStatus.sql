/****** Object:  Procedure [dbo].[sp_tblUserMobile_UpdateStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblUserMobile_UpdateStatus]
	-- Add the parameters for the stored procedure here
	@strUserCode	nvarchar(50),
	@intStatus		smallint,
	@strRemarks		nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @intCount INT
		DECLARE @ID INT
		SELECT @intCount = ISNULL(COUNT(mUser_ID), 0) FROM tblUserMobile NOLOCK 
		WHERE (mUser_Code = @strUserCode )

		IF @intCount = 0 
		BEGIN
			RAISERROR ('Fail to update user status, please try again.',16,1);  
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-1)
		END
		ELSE
		BEGIN
			UPDATE tblUserMobile
			SET
			mUser_Status = @intStatus, mUser_Remarks = @strRemarks
			WHERE mUser_Code = @strUserCode
		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
