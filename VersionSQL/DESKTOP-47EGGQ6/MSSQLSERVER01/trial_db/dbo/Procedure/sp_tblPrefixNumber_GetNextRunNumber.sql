/****** Object:  Procedure [dbo].[sp_tblPrefixNumber_GetNextRunNumber]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblPrefixNumber_GetNextRunNumber]
(
	@TrxType VARCHAR(100),
	@PrefixType VARCHAR(100),
	@BranchId INT,
	@strNextRunNumber VARCHAR(100) OUTPUT
)
AS
	
	BEGIN TRANSACTION

	SELECT @strNextRunNumber = 
		(AutoNumber_Prefix + RIGHT(REPLICATE('0', AutoNumber_RunningNoLength) + CAST(AutoNumber_RunningNo AS VARCHAR(10)), AutoNumber_RunningNoLength))
		FROM tblPrefixNumber 
		WHERE AutoNumber_TrxType = @TrxType AND AutoNumber_PrefixType = @PrefixType AND AutoNumber_BranchId = @BranchId

		UPDATE tblPrefixNumber
		SET AutoNumber_RunningNo = AutoNumber_RunningNo + 1
		WHERE AutoNumber_TrxType = @TrxType AND AutoNumber_PrefixType = @PrefixType AND AutoNumber_BranchId = @BranchId
	

	If @@ERROR <> 0 GoTo ErrorHandler
	
	COMMIT TRANSACTION
	RETURN (0)
	
ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
