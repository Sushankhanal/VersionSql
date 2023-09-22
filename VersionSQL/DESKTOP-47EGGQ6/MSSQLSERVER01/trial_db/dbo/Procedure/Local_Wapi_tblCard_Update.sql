/****** Object:  Procedure [dbo].[Local_Wapi_tblCard_Update]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Local_Wapi_tblCard_Update]
	@intID		int ,
	@strSerialNo	nvarchar(50),
	@intType	smallint,
	@intStatus	smallint,
	@strUsercode	nvarchar(50),
	@CardId             bigint = NULL OUTPUT
AS
BEGIN
	BEGIN TRANSACTION
	SET NOCOUNT ON;

Declare @strResultText nvarchar(255) = ''
Declare @intResultCode int = 0

Update tblCard Set Card_SerialNo = @strSerialNo, Card_Sync = 0, Card_Type = @intType, Card_Status = @intStatus
Where Card_ID = @intID
set @CardId=@intID
	
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
