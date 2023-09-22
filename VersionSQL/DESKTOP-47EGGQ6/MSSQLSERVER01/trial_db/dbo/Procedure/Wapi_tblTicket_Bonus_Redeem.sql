/****** Object:  Procedure [dbo].[Wapi_tblTicket_Bonus_Redeem]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblTicket_Bonus_Redeem]
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

	Update tblTicket_Bonus set Ticket_Status = 1, 
	Ticket_RedeemBy = @strUsercode, Ticket_UpdatedBy = @strUsercode,
	Ticket_RedeemDate = GETDATE(), Ticket_UpdatedDate = GETDATE() WHERE Ticket_ID = @ID

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
