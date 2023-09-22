/****** Object:  Procedure [dbo].[Wapi_tblPOSUser_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[Wapi_tblPOSUser_Update]
	-- Add the parameters for the stored procedure here
	@intID		int ,
	@strName	nvarchar(50),
	@intStatus	smallint,
	@strUsercode	nvarchar(50)
   
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0

		Update tblPOSUser Set
		POSUser_Name = @strName, POSUser_Status = @intStatus
		Where POSUser_ID = @intID

	set @intResultCode = @intID
	set @strResultText = 'Success'
	select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
		
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
