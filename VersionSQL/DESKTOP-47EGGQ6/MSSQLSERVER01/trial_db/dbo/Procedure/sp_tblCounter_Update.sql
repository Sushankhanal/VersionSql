/****** Object:  Procedure [dbo].[sp_tblCounter_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCounter_Update]
	-- Add the parameters for the stored procedure here
	@ID		int ,
	@strCode	nvarchar(50),
	@strName	nvarchar(50),
	@intStatus	smallint,
	@intType	smallint,
	@strUsercode		nvarchar(50),
	@intMachineID	bigint = 0,
	@strMachineName	nvarchar(50) = ''

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Update tblCounter Set
		Counter_Name = @strName, Counter_Cashless = @intType, Counter_Status = @intStatus,
		Counter_Machine_ID = @intMachineID, Counter_Machine_Name = @strMachineName
		Where Counter_ID = @ID

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
