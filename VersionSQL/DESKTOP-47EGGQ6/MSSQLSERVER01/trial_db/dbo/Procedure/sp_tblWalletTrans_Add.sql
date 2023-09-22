/****** Object:  Procedure [dbo].[sp_tblWalletTrans_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblWalletTrans_Add] 
	-- Add the parameters for the stored procedure here
	@intID				bigint	OUT,
	@strTransCode		nvarchar(50),
	@strUserCode		nvarchar(50),
	@intTransType		int, 
	@dblValue			money,
	@dblMoneyValue		money,
    @strRefCode			nvarchar(50),
	@strRemarks			nvarchar(max),
	@strCreatedBy		nvarchar(50),
	@strCampaignCode	nvarchar(50),
	@intPaymentMode		int
AS
BEGIN
	BEGIN TRANSACTION
	SET NOCOUNT ON;

	DECLARE @intPaymentModeAbleRefund int
    select @intPaymentModeAbleRefund = PaymentMode_AbleRefund from tblPaymentMode where PaymentMode_ID = @intPaymentMode
	DECLARE @intCount INT
	SELECT @intCount = ISNULL(COUNT(UWallet_ID), 0) FROM tblUserWallet NOLOCK 
	WHERE UWallet_UserCode = @strUserCode AND UWallet_Type = @intPaymentModeAbleRefund

	DECLARE @PrefixType VARCHAR(50), @intRowCount INT
	DECLARE @strWalletCode nvarchar(50)

	--- User don't have any wallet
	IF @intCount = 0
	BEGIN
		set @PrefixType = 'UserWallet'
		EXEC sp_tblPrefixNumber_GetNextRunNumber 'MobileUser', @PrefixType, 0, @strWalletCode OUTPUT

		INSERT INTO tblUserWallet
		(UWallet_UserCode, UWallet_Code, UWallet_Type, UWallet_Balance, UWallet_ModifiedDate)
		VALUES (@strUserCode,@strWalletCode,@intPaymentModeAbleRefund,0,GETDATE())
	END
	ELSE
	BEGIN
		select @strWalletCode = UWallet_Code FROM tblUserWallet NOLOCK 
		WHERE UWallet_UserCode = @strUserCode AND UWallet_Type = @intPaymentModeAbleRefund
	END

	Declare @intTransTypeSign int
	Declare @dblDefaultPointRate money
	select @intTransTypeSign = WTransType_Sign, 
	@dblDefaultPointRate = WTransType_DefaultPointRate  from tblWalletTransType 
	where WTransType_ID = @intTransType

	--set @PrefixType = 'WalletTrans'
	--EXEC sp_tblPrefixNumber_GetNextRunNumber 'WalletTrans', @PrefixType, 0, @strTransCode OUTPUT

	INSERT INTO tblWalletTrans
	(WalletTrans_Code, WalletTrans_UserCode, WalletTrans_WalletCode, WalletTrans_Type, 
	WalletTrans_Value, WalletTrans_MoneyValue, WalletTrans_RefCode, WalletTrans_Remarks, WalletTrans_CreatedBy, WalletTrans_CreatedDate, 
	WalletTrans_CampaignCode, WalletTrans_PaymentMode)
	VALUES (@strTransCode,@strUserCode,@strWalletCode,@intTransType,
	@dblValue * @intTransTypeSign,@dblMoneyValue,@strRefCode,@strRemarks,@strCreatedBy,GETDATE(),
	@strCampaignCode,@intPaymentMode)

	Update tblUserMobile set mUser_TotalBalance= mUser_TotalBalance + (@dblValue * @intTransTypeSign)
	where mUser_Code = @strUserCode

	Update tblUserWallet set UWallet_Balance= UWallet_Balance + (@dblValue * @intTransTypeSign)
	where UWallet_Code = @strWalletCode 

	if @dblDefaultPointRate <> 0
	BEGIN
		INSERT INTO tblPointTrans
		(PointTrans_Code, PointTrans_UserCode, PointTrans_Type, PointTrans_Value, PointTrans_PointValue, 
		PointTrans_RefCode, PointTrans_Remarks, PointTrans_CreatedBy, PointTrans_CreatedDate, PointTrans_CampaignCode, 
		PointTrans_QRCodeText, PointTrans_WalletAmt, PointTrans_Ratio)
		VALUES (
		@strTransCode,@strUserCode,@intTransType,@dblValue * @dblDefaultPointRate,@dblValue * @dblDefaultPointRate,
		@strRefCode,@strRemarks,@strCreatedBy,GETDATE(),'',
		'',@dblValue,@dblDefaultPointRate)
	END

	

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)

END
