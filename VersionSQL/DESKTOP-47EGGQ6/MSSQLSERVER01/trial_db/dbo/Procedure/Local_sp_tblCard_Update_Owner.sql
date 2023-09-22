/****** Object:  Procedure [dbo].[Local_sp_tblCard_Update_Owner]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_sp_tblCard_Update_Owner]
	-- Add the parameters for the stored procedure here
	@intCardID		bigint ,
	@intPlayerID	bigint,
	@CardId             bigint = NULL OUTPUT

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Update tblCard Set
	Card_CardOwner_ID = @intPlayerID
	Where Card_ID = @intCardID
	set @CardId=@intCardID
		
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
