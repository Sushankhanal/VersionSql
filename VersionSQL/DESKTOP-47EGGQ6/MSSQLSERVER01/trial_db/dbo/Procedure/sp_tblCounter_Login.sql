/****** Object:  Procedure [dbo].[sp_tblCounter_Login]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCounter_Login]
	-- Add the parameters for the stored procedure here
	@strLoginID		nvarchar(50),
	@strPassword	nvarchar(50),
	@strCounterCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@intCounterCashless	int OUT,
	@strUsercode	nvarchar(50) OUT,
	@strCounterPrinterName nvarchar(50) OUT,
	@strCounterKitchenName nvarchar(50) OUT,
	@dblPointRate money OUT,
	@strNotification nvarchar(500) OUT,
	@dblMinDisRate money OUT,
	@dblMinDisAmt money OUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		Declare @intHourToNotify int = 10

		set @intCounterCashless = 0
		set @dblPointRate = 0
		set @strNotification = ''
		set @dblMinDisRate = -1
		set @dblMinDisAmt = -1

		select @dblPointRate = WTransType_DefaultPointRate 
		from tblWalletTransType  where WTransType_Name ='Redeem'

		DECLARE @intCount INT
		DECLARE @ID INT
		SELECT @intCount = ISNULL(COUNT(POSUser_ID), 0) FROM tblPOSUser NOLOCK 
		WHERE POSUser_LoginID = @strLoginID and POSUser_Password = @strPassword
		and POSUser_Status = 0

		IF @intCount > 0 
		BEGIN
			DECLARE @intCount_Counter INT
			select @intCount_Counter = ISNULL(COUNT(Counter_ID), 0) from tblCounter where Counter_Code = @strCounterCode
			if @intCount_Counter > 0 
			BEGIN
				--DECLARE @strUserCode nvarchar(50)
				--DECLARE @intCounterCashless int
				SELECT @strUserCode = POSUser_Code,
				@dblMinDisRate = POSUser_MinGiveOutDiscountRate, @dblMinDisAmt = POSUser_MinGiveOutDiscountAmt FROM tblPOSUser NOLOCK 
				WHERE POSUser_LoginID = @strLoginID and POSUser_Password = @strPassword
				and POSUser_Status = 0

				select @intCounterCashless = Counter_Cashless, @strCounterPrinterName = Counter_ReceiptPrinterName, 
				@strCounterKitchenName = Counter_KitchenPrinterName
				 from tblCounter where Counter_Code = @strCounterCode

				DECLARE @intCount_CounterTrans INT
				select @intCount_CounterTrans = ISNULL(COUNT(CounterTrans_ID), 0) from tblCounterTrans 
				where CounterTrans_CounterCode = @strCounterCode 
				AND CounterTrans_IsSettlement = 0
				--and CounterTrans_UserCode = @strUserCode

				if @intCount_CounterTrans > 0 
				BEGIN
					-- Check and return notification
					--@strNotification
					Declare @dtOpenDate datetime
					select @dtOpenDate = CounterTrans_TransDate from tblCounterTrans 
					where CounterTrans_CounterCode = @strCounterCode 
					AND CounterTrans_IsSettlement = 0

					Declare @intHourOpen int =0
					select @intHourOpen = DATEDIFF(hh,@dtOpenDate,GETDATE())

					if @intHourOpen > @intHourToNotify
					BEGIN
						set @strNotification = 'This counter was opened counter over 10 hours, kindly perform settlement'
						COMMIT TRANSACTION
						SET NOCOUNT OFF
						RETURN (0)
					END
					ELSE
					BEGIN
						COMMIT TRANSACTION
						SET NOCOUNT OFF
						RETURN (0)
					END

					
				END
				ELSE
				BEGIN
					
					if @intCounterCashless = 0
					BEGIN
						INSERT INTO tblCounterTrans
						(CounterTrans_UserCode, CounterTrans_CounterCode, CounterTrans_OpenCash, CounterTrans_SettlementCash, CounterTrans_TransDate, 
						CounterTrans_SettleBy, CounterTrans_ModifiedBy, CounterTrans_ModifiedDate)
						VALUES (@strUserCode,@strCounterCode,0,0,GETDATE(),'',@strUserCode,GETDATE())

						COMMIT TRANSACTION
						SET NOCOUNT OFF
						RETURN (0)
					END
					ELSE
					BEGIN
						--- Login Successful, but havent open counter
						COMMIT TRANSACTION
						SET NOCOUNT OFF
						RETURN (1)
					END
					
				END
			END
			ELSE
			BEGIN
				--RAISERROR ('Invalid Counter Code.',16,1);  
				COMMIT TRANSACTION
				SET NOCOUNT OFF
				RETURN (-2)
			END
		END
		ELSE
		BEGIN
			--RAISERROR ('Invalid Login id and password. Please try again.',16,1);  
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
