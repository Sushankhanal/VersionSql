/****** Object:  Procedure [dbo].[Wapi_tblCardType_DeleteByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCardType_DeleteByID]
	-- Add the parameters for the stored procedure here
	@intID		bigint,
	@strUsercode		nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0
	DECLARE @intCount INT = 0
	SELECT @intCount = ISNULL(COUNT(Card_ID), 0) FROM tblCard NOLOCK 
	WHERE (Card_Type = @intID )

	IF @intCount = 0 
	BEGIN
		Delete from tblCardType WHERE CardType_ID = @intID
		set @intResultCode = @intID
		set @strResultText = 'Success'
		select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT

		 INSERT INTO  [POSv3].[dbo].[CloudSync] ( entityname, entityid, operation, Syncstatus)
            VALUES ( 'tblCardType',1, 'Delete', 1)

	END
	ELSE
	BEGIN
		set @intResultCode = -1
		set @strResultText = 'Card Type in used with another record(s)'
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
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
