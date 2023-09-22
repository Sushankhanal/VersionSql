/****** Object:  Procedure [dbo].[Wapi_tblProductCategory_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[Wapi_tblProductCategory_Update]
	-- Add the parameters for the stored procedure here
	@intID		int ,
	@strCategoryName	nvarchar(50),
	@intCategoryStatus	smallint,
	@strUsercode		nvarchar(50),
	@strOrderNumber		nvarchar(50),  
	@strRemarks		nvarchar(500)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0

	Update tblProductCategory set
	ProCategory_Name = @strCategoryName, ProCategory_Status = @intCategoryStatus, ProCategory_Order = @strOrderNumber, 
	ProCategory_Sync = 0, ProCategory_Desc = @strRemarks
	WHERE ProCategory_ID = @intID

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
