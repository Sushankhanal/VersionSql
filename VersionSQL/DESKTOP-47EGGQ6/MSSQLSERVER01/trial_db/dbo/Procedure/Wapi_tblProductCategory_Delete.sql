/****** Object:  Procedure [dbo].[Wapi_tblProductCategory_Delete]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[Wapi_tblProductCategory_Delete]
	-- Add the parameters for the stored procedure here
	@ID		bigint,
	@strUsercode		nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0

	DECLARE @strCode nvarchar(50) = ''
	SELECT @strCode = ProCategory_Code FROM tblProductCategory WHERE ProCategory_ID = @ID 

	DECLARE @intCount INT = 0
	SELECT @intCount = ISNULL(COUNT(Product_ID), 0) FROM tblProduct NOLOCK WHERE (Product_CategoryCode = @strCode)
	
	IF @intCount = 0 
	BEGIN
		Delete from tblProductCategory WHERE ProCategory_ID = @ID
		set @intResultCode = @ID
		set @strResultText = 'Success'
		select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT

	END
	ELSE
	BEGIN
		set @intResultCode = -1
		set @strResultText = 'Product category in used with product record(s)'
		select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
	END


	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
