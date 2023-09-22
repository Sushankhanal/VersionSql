/****** Object:  Procedure [dbo].[Wapi_tblWalletTransType_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblWalletTransType_Update]
	-- Add the parameters for the stored procedure here
	@ID		int ,
	@dblDefaultPointRate	money,
	@dblPointRateConvertion	money
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0

	Update tblWalletTransType Set
	WTransType_DefaultPointRate = @dblDefaultPointRate, WTransType_PointRateConvertion = @dblPointRateConvertion
	Where WTransType_ID = @ID

		set @intResultCode = @ID
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
