/****** Object:  Procedure [dbo].[sp_tblCounterTrans_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCounterTrans_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strUserCode	nvarchar(50),
	@strCounterCode	nvarchar(50),
	@dblInitialCash	money

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(CounterTrans_ID), 0) FROM tblCounterTrans NOLOCK 
		WHERE CounterTrans_UserCode = @strUserCode AND CounterTrans_CounterCode = @strCounterCode
		AND CounterTrans_IsSettlement = 0
		
		IF @intCount = 0 
		BEGIN
			
			--Declare @strCompanyCode nvarchar(50)
			--select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

			INSERT INTO tblCounterTrans
			(CounterTrans_UserCode, CounterTrans_CounterCode, CounterTrans_OpenCash, CounterTrans_TransDate,
			CounterTrans_ModifiedBy, CounterTrans_ModifiedDate, CounterTrans_SettlementCash)
			VALUES (
			@strUserCode, @strCounterCode, @dblInitialCash, GETDATE(), @strUserCode, GETDATE(), 0)
			SELECT @ID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			--RAISERROR ('Error',16,1);  
			COMMIT TRANSACTION
			SET NOCOUNT OFF
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
