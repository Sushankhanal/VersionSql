/****** Object:  Procedure [dbo].[sp_CheckBalance]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Header_Card_Add 'user001','','COUNTER1','Hallaway01',10,0,0,0,10,'',xml,'','',2,'',6,'','','',0
CREATE PROCEDURE [dbo].[sp_CheckBalance]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@intUserID			int,
	@strRandomKey		nvarchar(1024),
	@strCardNumber		nvarchar(50),
	@strClientFullName	nvarchar(50) OUT,
	@strClientBalance	money OUT,
	@strClientPoint		decimal(38, 10) OUT,
	@strClientPointRedeemRate	money OUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intUserID = 0
	BEGIN
		if @strCardNumber = ''
		BEGIN
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-10)
		END

		DECLARE @intCount_Card int
		DECLARE @strMobileUser	nvarchar(50)
		select @intCount_Card = COUNT(Card_ID) from tblCard where Card_SerialNo = @strCardNumber
		set @strMobileUser = ''

		if @intCount_Card = 0
		BEGIN
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-20)
		END

		if @intCount_Card > 0
		BEGIN
			select @strMobileUser = Card_MobileUser from tblCard where Card_SerialNo = @strCardNumber
		END

		if @strMobileUser = ''
		BEGIN
			select  @strClientBalance = Card_Balance, @strClientPoint = Card_Point from tblCard where Card_SerialNo = @strCardNumber
			set @strClientFullName = @strCardNumber

			--set @strClientPoint = 0
			--set @strClientPointRedeemRate = 0
		END
		ELSE
		BEGIN
			select  @strClientBalance = mUser_TotalBalance, @strClientFullName = mUser_FullName, @strClientPoint = mUser_TotalPoint  
			from tblUserMobile where mUser_Code = @strMobileUser	
		END
		select @strClientPointRedeemRate = WTransType_DefaultPointRate from tblWalletTransType  where WTransType_Name ='Redeem'
			set @strClientPointRedeemRate = @strClientPointRedeemRate * -1
	END
	ELSE
	BEGIN
		DECLARE @strClientRandomCode nvarchar(1024)
		Declare @strClientUserCode nvarchar(50)
		set @strClientUserCode = ''
		set @strClientRandomCode = ''
		set @strClientBalance = 0
		select @strClientUserCode = mUser_Code, @strClientRandomCode = ISNULL(mUser_RandomCode,''),
			@strClientFullName = mUser_FullName, @strClientBalance = mUser_TotalBalance
			from tblUserMobile where mUser_ID = @intUserID
	
		if @strClientUserCode = ''
		BEGIN
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-6)
		END

		if @strClientRandomCode <> @strRandomKey
		BEGIN
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-7)
		END
		
		select  @strClientBalance = mUser_TotalBalance, @strClientFullName = mUser_FullName, @strClientPoint = mUser_TotalPoint  
		from tblUserMobile where mUser_ID = @intUserID

		select @strClientPointRedeemRate = WTransType_DefaultPointRate from tblWalletTransType  where WTransType_Name ='Redeem'
		set @strClientPointRedeemRate = @strClientPointRedeemRate * -1
	END


	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)
	
	

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
