/****** Object:  Procedure [dbo].[sp_tblWalletTransTemp_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblWalletTransTemp_Add] 
	-- Add the parameters for the stored procedure here
	@strTransCode		nvarchar(50) OUT,
	@strUserCode		nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	SET NOCOUNT ON;

	--DECLARE @intPaymentModeAbleRefund int
 --   select @intPaymentModeAbleRefund = PaymentMode_AbleRefund from tblPaymentMode where PaymentMode_ID = @intPaymentMode
	--DECLARE @intCount INT
	--SELECT @intCount = ISNULL(COUNT(UWallet_ID), 0) FROM tblUserWallet NOLOCK 
	--WHERE UWallet_UserCode = @strUserCode AND UWallet_Type = @intPaymentModeAbleRefund

	DECLARE @PrefixType VARCHAR(50), @intRowCount INT
	DECLARE @strWalletCode nvarchar(50)

	set @PrefixType = 'WalletTrans'
	EXEC sp_tblPrefixNumber_GetNextRunNumber 'WalletTrans', @PrefixType, 0, @strTransCode OUTPUT

	
	INSERT INTO tblWalletTransTemp
	(WalletTrans_Code, WalletTrans_UserCode, WalletTrans_CreateDate,WalletTrans_Status)
	VALUES (@strTransCode,@strUserCode,GETDATE(),0)

	
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)

END
