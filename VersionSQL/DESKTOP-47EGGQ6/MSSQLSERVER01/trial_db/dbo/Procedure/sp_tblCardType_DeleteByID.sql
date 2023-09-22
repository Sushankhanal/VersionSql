/****** Object:  Procedure [dbo].[sp_tblCardType_DeleteByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[sp_tblCardType_DeleteByID]
	-- Add the parameters for the stored procedure here
	@ID		bigint,
	@strUsercode		nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	DECLARE @intCount INT = 0
		SELECT @intCount = ISNULL(COUNT(Card_ID), 0) FROM tblCard NOLOCK 
		WHERE (Card_Type = @ID )

		IF @intCount = 0 
		BEGIN
			Delete from tblCardType WHERE CardType_ID = @ID
		END
		ELSE
		BEGIN
			RAISERROR ('Card Type in used with another record(s)',16,1);  
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
