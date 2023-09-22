/****** Object:  Procedure [dbo].[Local_sp_tblCard_ResetPin]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_sp_tblCard_ResetPin]
	-- Add the parameters for the stored procedure here
	@intCardID		bigint,
	@intResetType	int, -- 0:Reset Default, 1: Manual Reset
	@strOldPassword	nvarchar(50),
	@strNewPassword	nvarchar(50),
	@CardId             bigint = NULL OUTPUT

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intResetType = 0
	BEGIN
		update tblCard set tblCard_pin = '123456', Card_isPinReset = 0 where Card_ID = @intCardID
		set @CardId=@intCardID
	END
	ELSE
	BEGIN
		if (select COUNT(Card_ID) from tblCard where Card_ID = @intCardID and tblCard_pin = @strOldPassword) = 0
		BEGIN
			RAISERROR ('Invalid Old Pin',16,1);  
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN -1

		END
		ELSE
		BEGIN
			Update tblCard Set tblCard_pin = @strNewPassword, Card_isPinReset = 1
			Where Card_ID = @intCardID
			set @CardId=@intCardID
		END
		
	END

	
		
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
