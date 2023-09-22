/****** Object:  Procedure [dbo].[Local_sp_tblCardOwner_AssignPrintCardUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_sp_tblCardOwner_AssignPrintCardUpdate]
	-- Add the parameters for the stored procedure here
	@intID				bigint output ,
	@intNewCardID		bigint, 
	@intPlayerID		bigint,
	@strCreatedBy		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@strPic				nvarchar(50),
	@strOldCardNumber	nvarchar(50),
	@intTransType		int, -- 0: New Assign, 1: Transfer
	@CardId             bigint = NULL OUTPUT

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		Declare @strCardNumber nvarchar(50) = ''
		DECLARE @PrefixType VARCHAR(50) = ''
		Declare @strReceiptNo nvarchar(50) = ''

		DECLARE @intCount INT
		DECLARE @ID INT
		SELECT @intCount = ISNULL(COUNT(Card_ID), 0) FROM tblCard NOLOCK WHERE Card_ID = @intNewCardID

		if @intCount = 0
		BEGIN
			RAISERROR ('Invalid Card Number. Please try another.',16,1);  
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (-1)
		END

		if @intTransType = 1
		BEGIN
			SELECT @intCount = ISNULL(COUNT(Card_ID), 0) FROM tblCard NOLOCK WHERE Card_SerialNo = @strOldCardNumber

			if @intCount = 0
			BEGIN
				RAISERROR ('Invalid Old Card Number. Please try another.',16,1);  
				ROLLBACK TRANSACTION
				SET NOCOUNT OFF
				RETURN (-1)
			END
		END

		
		SELECT @strCardNumber = Card_SerialNo FROM tblCard NOLOCK WHERE Card_ID = @intNewCardID

		set @intCount = 0
		IF @intCount = 0 
		BEGIN
			Declare @strMobileNumber nvarchar(50) = ''
			select @strMobileNumber = C.CardOwner_MobileNumber from tblCardOwner (NOLOCK) C where C.CardOwner_ID = @intPlayerID

			Update tblCard set Card_img = @strPic, Card_Status = 0, Card_PrintDate = GETDATE() where Card_ID = @intNewCardID
			set @CardId = @intNewCardID
			
			SELECT @intID = @intNewCardID

			if @intTransType = 1
			BEGIN
				Declare @dblCard_Balance money = 0 
				Declare @dblCard_Point decimal(38, 10) = 0  
				Declare @dblCard_Balance_Cashable_No money = 0  
				Declare @dblCard_Balance_Cashable money = 0 
				Declare @dblCard_PointAccumulate decimal(38, 10) = 0 
				Declare @dblCard_Point_Tier decimal(38, 10) = 0  
				Declare @dblCard_Point_Hidden decimal(38, 10) = 0 
				Declare @intPaymentType int = 1
				Declare @intItemSign int = 0
				Declare @intCardTransType int = 0

				select @dblCard_Balance = Card_Balance,@dblCard_Point = Card_Point, @dblCard_Balance_Cashable_No = Card_Balance_Cashable_No, 
				@dblCard_Balance_Cashable = Card_Balance_Cashable,
				@dblCard_PointAccumulate = Card_PointAccumulate, @dblCard_Point_Tier = Card_Point_Tier, 
				@dblCard_Point_Hidden = Card_Point_Hidden from tblCard C (NOLOCK)
				where Card_SerialNo = @strOldCardNumber

				------ Credit Transfer IN
				set @PrefixType = 'Receipt'
				
				set @intItemSign = 1
				set @intCardTransType = 4
				if @dblCard_Balance <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strReceiptNo OUTPUT
					INSERT INTO tblCard_Trans
					(CardTrans_Code, CardTrans_SerialNo, CardTrans_Date, CardTrans_Type, CardTrans_Value, CardTrans_MoneyValue, 
					CardTrans_RefCode, CardTrans_CreatedBy, CardTrans_CreatedDate, CardTrans_CampaignCode, 
					CardTrans_PaymentMode, CardTrans_OldCardNumber)
					VALUES (
					@strReceiptNo,@strCardNumber,GETDATE(),@intCardTransType,@dblCard_Balance * @intItemSign,@dblCard_Balance,
					@strReceiptNo,@strCreatedBy,GETDATE(),'',@intPaymentType, @strOldCardNumber)
				END

				

				set @intCardTransType = 31
				if @dblCard_Balance_Cashable <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strReceiptNo OUTPUT
					INSERT INTO tblCard_Trans
					(CardTrans_Code, CardTrans_SerialNo, CardTrans_Date, CardTrans_Type, CardTrans_Value, CardTrans_MoneyValue, 
					CardTrans_RefCode, CardTrans_CreatedBy, CardTrans_CreatedDate, CardTrans_CampaignCode, 
					CardTrans_PaymentMode, CardTrans_OldCardNumber)
					VALUES (
					@strReceiptNo,@strCardNumber,GETDATE(),@intCardTransType,@dblCard_Balance_Cashable * @intItemSign,@dblCard_Balance_Cashable,
					@strReceiptNo,@strCreatedBy,GETDATE(),'',@intPaymentType, @strOldCardNumber)
				END
				
				set @intCardTransType = 33
				if @dblCard_Balance_Cashable_No <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strReceiptNo OUTPUT
					INSERT INTO tblCard_Trans
					(CardTrans_Code, CardTrans_SerialNo, CardTrans_Date, CardTrans_Type, CardTrans_Value, CardTrans_MoneyValue, 
					CardTrans_RefCode, CardTrans_CreatedBy, CardTrans_CreatedDate, CardTrans_CampaignCode, 
					CardTrans_PaymentMode, CardTrans_OldCardNumber)
					VALUES (
					@strReceiptNo,@strCardNumber,GETDATE(),@intCardTransType,@dblCard_Balance_Cashable_No * @intItemSign,@dblCard_Balance_Cashable_No,
					@strReceiptNo,@strCreatedBy,GETDATE(),'',@intPaymentType, @strOldCardNumber)
				END
				
				----- Credit Transfer out 
				set @intItemSign = -1
				set @intCardTransType = 5
				if @dblCard_Balance <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strReceiptNo OUTPUT
					INSERT INTO tblCard_Trans
					(CardTrans_Code, CardTrans_SerialNo, CardTrans_Date, CardTrans_Type, CardTrans_Value, CardTrans_MoneyValue, 
					CardTrans_RefCode, CardTrans_CreatedBy, CardTrans_CreatedDate, CardTrans_CampaignCode, 
					CardTrans_PaymentMode, CardTrans_OldCardNumber)
					VALUES (
					@strReceiptNo,@strOldCardNumber,GETDATE(),@intCardTransType,@dblCard_Balance * @intItemSign,@dblCard_Balance,
					@strReceiptNo,@strCreatedBy,GETDATE(),'',@intPaymentType,@strCardNumber)
				END

				

				set @intCardTransType = 32
				if @dblCard_Balance_Cashable <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strReceiptNo OUTPUT
					INSERT INTO tblCard_Trans
					(CardTrans_Code, CardTrans_SerialNo, CardTrans_Date, CardTrans_Type, CardTrans_Value, CardTrans_MoneyValue, 
					CardTrans_RefCode, CardTrans_CreatedBy, CardTrans_CreatedDate, CardTrans_CampaignCode, 
					CardTrans_PaymentMode, CardTrans_OldCardNumber)
					VALUES (
					@strReceiptNo,@strOldCardNumber,GETDATE(),@intCardTransType,@dblCard_Balance_Cashable * @intItemSign,@dblCard_Balance_Cashable,
					@strReceiptNo,@strCreatedBy,GETDATE(),'',@intPaymentType,@strCardNumber)
				END

				

				set @intCardTransType = 34
				if @dblCard_Balance_Cashable_No <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strReceiptNo OUTPUT
					INSERT INTO tblCard_Trans
					(CardTrans_Code, CardTrans_SerialNo, CardTrans_Date, CardTrans_Type, CardTrans_Value, CardTrans_MoneyValue, 
					CardTrans_RefCode, CardTrans_CreatedBy, CardTrans_CreatedDate, CardTrans_CampaignCode, 
					CardTrans_PaymentMode, CardTrans_OldCardNumber)
					VALUES (
					@strReceiptNo,@strOldCardNumber,GETDATE(),@intCardTransType,@dblCard_Balance_Cashable_No * @intItemSign,@dblCard_Balance_Cashable_No,
					@strReceiptNo,@strCreatedBy,GETDATE(),'',@intPaymentType,@strCardNumber)
				END
				
				--- Transfer IN Point
				set @intItemSign = 1
				--Declare @dblCard_Point money = 0  
				--Declare @dblCard_PointAccumulate money = 0 
				--Declare @dblCard_Point_Tier money = 0  
				--Declare @dblCard_Point_Hidden money = 0 
				Declare @strTransNo nvarchar(50) = ''
				Declare @intPointType int = 0
				set @PrefixType = 'CardTrans'
				
				set @intPointType = 0
				
				if @dblCard_Point <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'CardTrans', @PrefixType, 0, @strTransNo OUTPUT
					INSERT INTO tblCardPointTrans
					(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, CardPointTrans_PointValue, 
					CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, CardPointTrans_CreatedDate, 
					CardPointTrans_CampaignCode, CardPointTrans_QRCodeText, CardPointTrans_WalletAmt, CardPointTrans_Ratio, CardPointTrans_LocalTransID, CardPointTrans_BranchID,
					CardPointTrans_ApprovedBy, CardPointTrans_ApprovedDate, CardPointTrans_PointType, CardPointTrans_OldCardNumber)
					VALUES (
					@strTransNo,@strCardNumber,@intTransType,@dblCard_Point * @intItemSign,@dblCard_Point,
					@intPlayerID,'',@strCreatedBy,GETDATE(),
					'','',0,0,0,0, @strCreatedBy, GETDATE(), @intPointType, @strOldCardNumber)
				END

				

				set @intPointType = 1
				if @dblCard_Point_Tier <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'CardTrans', @PrefixType, 0, @strTransNo OUTPUT
					INSERT INTO tblCardPointTrans
					(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, CardPointTrans_PointValue, 
					CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, CardPointTrans_CreatedDate, 
					CardPointTrans_CampaignCode, CardPointTrans_QRCodeText, CardPointTrans_WalletAmt, CardPointTrans_Ratio, CardPointTrans_LocalTransID, CardPointTrans_BranchID,
					CardPointTrans_ApprovedBy, CardPointTrans_ApprovedDate, CardPointTrans_PointType, CardPointTrans_OldCardNumber)
					VALUES (
					@strTransNo,@strCardNumber,@intTransType,@dblCard_Point_Tier * @intItemSign,@dblCard_Point_Tier,
					@intPlayerID,'',@strCreatedBy,GETDATE(),
					'','',0,0,0,0, @strCreatedBy, GETDATE(), @intPointType, @strOldCardNumber)
				END

				

				set @intPointType = 2
				if @dblCard_Point_Hidden <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'CardTrans', @PrefixType, 0, @strTransNo OUTPUT
					INSERT INTO tblCardPointTrans
					(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, CardPointTrans_PointValue, 
					CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, CardPointTrans_CreatedDate, 
					CardPointTrans_CampaignCode, CardPointTrans_QRCodeText, CardPointTrans_WalletAmt, CardPointTrans_Ratio, CardPointTrans_LocalTransID, CardPointTrans_BranchID,
					CardPointTrans_ApprovedBy, CardPointTrans_ApprovedDate, CardPointTrans_PointType, CardPointTrans_OldCardNumber)
					VALUES (
					@strTransNo,@strCardNumber,@intTransType,@dblCard_Point_Hidden * @intItemSign,@dblCard_Point_Hidden,
					@intPlayerID,'',@strCreatedBy,GETDATE(),
					'','',0,0,0,0, @strCreatedBy, GETDATE(), @intPointType, @strOldCardNumber)
				END

				

				--- Transfer Out Point
				set @intItemSign = -1
				
				set @intPointType = 0
				
				if @dblCard_Point <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'CardTrans', @PrefixType, 0, @strTransNo OUTPUT
					INSERT INTO tblCardPointTrans
					(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, CardPointTrans_PointValue, 
					CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, CardPointTrans_CreatedDate, 
					CardPointTrans_CampaignCode, CardPointTrans_QRCodeText, CardPointTrans_WalletAmt, CardPointTrans_Ratio, CardPointTrans_LocalTransID, CardPointTrans_BranchID,
					CardPointTrans_ApprovedBy, CardPointTrans_ApprovedDate, CardPointTrans_PointType, CardPointTrans_OldCardNumber)
					VALUES (
					@strTransNo,@strOldCardNumber,@intTransType,@dblCard_Point * @intItemSign,@dblCard_Point,
					@intPlayerID,'',@strCreatedBy,GETDATE(),
					'','',0,0,0,0, @strCreatedBy, GETDATE(), @intPointType, @strCardNumber)
				END

				

				set @intPointType = 1
				if @dblCard_Point_Tier <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'CardTrans', @PrefixType, 0, @strTransNo OUTPUT
					INSERT INTO tblCardPointTrans
					(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, CardPointTrans_PointValue, 
					CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, CardPointTrans_CreatedDate, 
					CardPointTrans_CampaignCode, CardPointTrans_QRCodeText, CardPointTrans_WalletAmt, CardPointTrans_Ratio, CardPointTrans_LocalTransID, CardPointTrans_BranchID,
					CardPointTrans_ApprovedBy, CardPointTrans_ApprovedDate, CardPointTrans_PointType, CardPointTrans_OldCardNumber)
					VALUES (
					@strTransNo,@strOldCardNumber,@intTransType,@dblCard_Point_Tier * @intItemSign,@dblCard_Point_Tier,
					@intPlayerID,'',@strCreatedBy,GETDATE(),
					'','',0,0,0,0, @strCreatedBy, GETDATE(), @intPointType, @strCardNumber)
				END

				

				set @intPointType = 2
				if @dblCard_Point_Hidden <> 0
				BEGIN
					EXEC sp_tblPrefixNumber_GetNextRunNumber 'CardTrans', @PrefixType, 0, @strTransNo OUTPUT
					INSERT INTO tblCardPointTrans
					(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, CardPointTrans_PointValue, 
					CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, CardPointTrans_CreatedDate, 
					CardPointTrans_CampaignCode, CardPointTrans_QRCodeText, CardPointTrans_WalletAmt, CardPointTrans_Ratio, CardPointTrans_LocalTransID, CardPointTrans_BranchID,
					CardPointTrans_ApprovedBy, CardPointTrans_ApprovedDate, CardPointTrans_PointType, CardPointTrans_OldCardNumber)
					VALUES (
					@strTransNo,@strOldCardNumber,@intTransType,@dblCard_Point_Hidden * @intItemSign,@dblCard_Point_Hidden,
					@intPlayerID,'',@strCreatedBy,GETDATE(),
					'','',0,0,0,0, @strCreatedBy, GETDATE(), @intPointType, @strCardNumber)
				END
				
				Update tblCard set  Card_Balance = @dblCard_Balance, Card_Point = @dblCard_Point, Card_Balance_Cashable_No = @dblCard_Balance_Cashable_No,
				Card_Balance_Cashable = @dblCard_Balance_Cashable, Card_PointAccumulate = @dblCard_PointAccumulate, 
				Card_Point_Tier = @dblCard_Point_Tier, Card_Point_Hidden = @dblCard_Point_Hidden
				where Card_ID = @intNewCardID
				set @CardId= @intNewCardID

				Update tblCard set  Card_Balance = 0, Card_Point = 0, Card_Balance_Cashable_No = 0,
				Card_Balance_Cashable = 0, Card_PointAccumulate = 0, 
				Card_Point_Tier = 0, Card_Point_Hidden = 0
				where Card_SerialNo = @strOldCardNumber	
				set @CardId=@strCardNumber
			END

			

		END
		
		

If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
