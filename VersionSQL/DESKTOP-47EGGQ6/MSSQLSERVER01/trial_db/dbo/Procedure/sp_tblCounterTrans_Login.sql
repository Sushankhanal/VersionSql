/****** Object:  Procedure [dbo].[sp_tblCounterTrans_Login]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCounterTrans_Login]
	-- Add the parameters for the stored procedure here
	@strUserCode	nvarchar(50),
	@strCounterCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@dblOpenCash	money
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO tblCounterTrans
	(CounterTrans_UserCode, CounterTrans_CounterCode, CounterTrans_OpenCash, CounterTrans_SettlementCash, CounterTrans_TransDate, 
	CounterTrans_SettleBy, CounterTrans_ModifiedBy, CounterTrans_ModifiedDate)
	VALUES (@strUserCode,@strCounterCode,@dblOpenCash,0,GETDATE(),'',@strUserCode,GETDATE())


	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
