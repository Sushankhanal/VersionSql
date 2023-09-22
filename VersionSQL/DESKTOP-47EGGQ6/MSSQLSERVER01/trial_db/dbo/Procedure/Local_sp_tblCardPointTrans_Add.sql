/****** Object:  Procedure [dbo].[Local_sp_tblCardPointTrans_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec sp_tblCardPointTrans_Add 0,0,'0010460954'5,300,'','',
create PROCEDURE [dbo].[Local_sp_tblCardPointTrans_Add]
	-- Add the parameters for the stored procedure here
	@ID			int OUT,
	@intPlayerID	bigint,
	@strSerialNo	nvarchar(50),
	@intTransType	smallint,
	@dblPointAmt	decimal(38, 10),
	@strRemarks		nvarchar(500),
	@strUsercode		nvarchar(50),
	@strUsername		nvarchar(50),
	@strPassword		nvarchar(50),
	@intPointType		int = 0,
	@CardId             bigint = NULL OUTPUT

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @intCount INT
		
		select @intCount = COUNT(POSUser_ID) from tblPOSUser where POSUser_LoginID = @strUsername and POSUser_Password = @strPassword AND POSUser_UserType= 1
		IF @intCount <> 0 
		BEGIN
			Declare @strManagerUserCode nvarchar(50) = ''
			select @strManagerUserCode = POSUser_Code from tblPOSUser where POSUser_LoginID = @strUsername and POSUser_Password = @strPassword AND POSUser_UserType= 1

			Declare @intItemSign int = 0
			select @intItemSign = WTransType_Sign from tblWalletTransType where WTransType_ID = @intTransType
			if (@dblPointAmt * @intItemSign) < 0
			BEGIN
				Declare @dblCurrentPoint decimal(38, 10) = 0
				select @dblCurrentPoint = Card_Point from tblCard where Card_SerialNo = @strSerialNo
				if (@dblCurrentPoint - @dblPointAmt)  < 0
				BEGIN
					RAISERROR ('Total Point can not adjust to negative.',16,1);  
					ROLLBACK TRANSACTION
					SET NOCOUNT OFF
					RETURN (-1)
				END
			END
			
			Declare @strTransNo nvarchar(50) = ''
			DECLARE @PrefixType VARCHAR(50), @intRowCount INT
			set @PrefixType = 'CardTrans'
			EXEC sp_tblPrefixNumber_GetNextRunNumber 'CardTrans', @PrefixType, 0, @strTransNo OUTPUT

			
			INSERT INTO tblCardPointTrans
			(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, CardPointTrans_PointValue, 
			CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, CardPointTrans_CreatedDate, 
			CardPointTrans_CampaignCode, CardPointTrans_QRCodeText, CardPointTrans_WalletAmt, CardPointTrans_Ratio, CardPointTrans_LocalTransID, CardPointTrans_BranchID,
			CardPointTrans_ApprovedBy, CardPointTrans_ApprovedDate, CardPointTrans_PointType)
			VALUES (
			@strTransNo,@strSerialNo,@intTransType,@dblPointAmt * @intItemSign,@dblPointAmt,
			@intPlayerID,@strRemarks,@strUsercode,GETDATE(),
			'','',0,0,0,0, @strManagerUserCode, GETDATE(), @intPointType)

			if @intPointType = 0
			BEGIN
				Update tblCard set Card_Point = Card_Point + (@dblPointAmt * @intItemSign) where Card_SerialNo = @strSerialNo 
				set @CardId=@strSerialNo
				if (@dblPointAmt * @intItemSign) > 0
				BEGIN
					Update tblCard set Card_PointAccumulate = Card_PointAccumulate + (@dblPointAmt * @intItemSign) where Card_SerialNo = @strSerialNo 
				set @CardId=@strSerialNo
				END
			END
			ELSE if @intPointType = 1
			BEGIN
				Update tblCard set Card_Point_Tier = Card_Point_Tier + (@dblPointAmt * @intItemSign) where Card_SerialNo = @strSerialNo 
			set @CardId=@strSerialNo
			END
			ELSE if @intPointType = 2
			BEGIN
				Update tblCard set Card_Point_Hidden = Card_Point_Hidden + (@dblPointAmt * @intItemSign) where Card_SerialNo = @strSerialNo 
			set @CardId=@strSerialNo
			END

			SELECT @ID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			RAISERROR ('Invalid username password.',16,1);  
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
