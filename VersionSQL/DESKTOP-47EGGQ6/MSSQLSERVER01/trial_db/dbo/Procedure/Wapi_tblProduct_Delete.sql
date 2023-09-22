/****** Object:  Procedure [dbo].[Wapi_tblProduct_Delete]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblProduct_Delete]
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
	SELECT @strCode = Product_ItemCode FROM tblProduct WHERE Product_ID = @ID 

	DECLARE @intCount INT = 0
	SELECT @intCount = ISNULL(COUNT(PaymentD_ID), 0) FROM tblPayment_Details NOLOCK WHERE (PaymentD_ItemCode = @strCode)
	
	IF @intCount = 0 
	BEGIN
		Delete from tblProduct WHERE Product_ID = @ID
		set @intResultCode = @ID
		set @strResultText = 'Success'
		select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
	END
	ELSE
	BEGIN
		set @intResultCode = -1
		set @strResultText = 'Item Code in used with another record(s)'
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
