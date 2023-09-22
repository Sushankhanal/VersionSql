/****** Object:  Procedure [dbo].[sp_tblPOSUser_DeleteByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[sp_tblPOSUser_DeleteByID]
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
	SELECT @strCode = POSUser_Code FROM tblPOSUser WHERE POSUser_ID = @ID 

	DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(Payment_ID), 0) FROM tblPayment_Header NOLOCK 
		WHERE (Payment_CreatedBy = @strCode )

		IF @intCount = 0 
		BEGIN
			Delete from tblPOSUser WHERE POSUser_ID = @ID
		END
		ELSE
		BEGIN
			RAISERROR ('Cashier in used with another record(s)',16,1);  
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
