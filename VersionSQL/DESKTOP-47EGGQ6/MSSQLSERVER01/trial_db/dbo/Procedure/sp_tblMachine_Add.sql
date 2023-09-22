/****** Object:  Procedure [dbo].[sp_tblMachine_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblMachine_Add]
	-- Add the parameters for the stored procedure here
	@ID				int OUT,
	@intMachineID	bigint,
	@strMachineName	nvarchar(50),
	@intBaseID		bigint,
	@intBankID		bigint,
	@intZoneID		bigint,
	@intFloorID		bigint,
	@intGameID		bigint,
	@intModelID		bigint
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		
		DECLARE @intCount INT = 0
		SELECT @intCount = ISNULL(COUNT(Machine_ID), 0) FROM tblMachine NOLOCK WHERE (Machine_ID = @intMachineID )
		
		IF @intCount = 0 
		BEGIN
			INSERT INTO tblMachine
			(Machine_ID, Machine_Name, Base_ID, Bank_ID, Zone_ID, Floor_ID, Game_ID, Model_ID)
			VALUES (
			@intMachineID,@strMachineName,@intBaseID,@intBankID,@intZoneID,@intFloorID,@intGameID,@intModelID)
		END
		ELSE
		BEGIN
			Update tblMachine set
			Machine_Name = @strMachineName, Base_ID = @intBaseID, Bank_ID = @intBankID, 
			Zone_ID = @intZoneID, Floor_ID = @intFloorID, Game_ID = @intGameID, Model_ID = @intModelID
			where Machine_ID = @intMachineID
		END

		SELECT @ID = @intMachineID

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
