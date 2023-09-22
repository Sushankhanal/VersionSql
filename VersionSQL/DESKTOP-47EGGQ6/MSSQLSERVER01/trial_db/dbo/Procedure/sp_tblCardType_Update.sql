/****** Object:  Procedure [dbo].[sp_tblCardType_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec sp_tblCard_Update 0,'00112233445566',1,0,'','',0,''
Create PROCEDURE [dbo].[sp_tblCardType_Update]
	-- Add the parameters for the stored procedure here
	@ID		int ,
	@strName	nvarchar(50),
	@intStatus	smallint,
	@dblRate	smallint,
	@strUsercode	nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Update tblCardType Set
		CardType_Name = @strName, CardType_Rate = @dblRate, CardType_Status = @intStatus,
		CardType_UpdatedBy = @strUsercode, CardType_UpdatedDate = GETDATE()
		Where CardType_ID = @ID

		
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
