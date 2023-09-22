/****** Object:  Procedure [dbo].[sp_tblCounter_DeleteByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCounter_DeleteByID]
	-- Add the parameters for the stored procedure here
	@ID		bigint,
	@strUsercode		nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @strCode nvarchar(50)
	SELECT @strCode = Counter_Code FROM tblCounter WHERE Counter_ID = @ID 

	DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(Payment_ID), 0) FROM tblPayment_Header NOLOCK 
		WHERE (Payment_CounterCode = @strCode )

		IF @intCount = 0 
		BEGIN
			Delete from tblCounter WHERE Counter_ID = @ID
		END
		ELSE
		BEGIN
			RAISERROR ('Counter in used with another record(s)',16,1);  
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
