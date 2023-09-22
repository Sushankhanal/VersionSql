/****** Object:  Procedure [dbo].[Local_sp_tblCardOwner_AssignPrintCard]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_sp_tblCardOwner_AssignPrintCard]
	-- Add the parameters for the stored procedure here
	@intID				bigint output ,
	@strCardNumber		nvarchar(50), 
	@intCardType		int,
	@intPlayerID		bigint,
	@strCreatedBy		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@CardId             bigint = NULL OUTPUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
		DECLARE @intCount INT
		DECLARE @ID INT
		SELECT @intCount = ISNULL(COUNT(Card_ID), 0) FROM tblCard NOLOCK WHERE (Card_SerialNo = @strCardNumber )

		if @intCount > 0
		BEGIN
			RAISERROR ('Card Number already registered. Please try another.',16,1);  
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (-1)
		END

		set @intCount = 0
		IF @intCount = 0 
		BEGIN
			Declare @strMobileNumber nvarchar(50) = ''
			select @strMobileNumber = C.CardOwner_MobileNumber from tblCardOwner (NOLOCK) C where C.CardOwner_ID = @intPlayerID

			INSERT INTO tblCard
			(Card_SerialNo, Card_Status, Card_MobileUser, Card_Balance, Card_CreatedBy, Card_CreatedDate, 
			Card_Point, Card_CompanyCode, Card_CardOwner_ID, Card_Sync, Card_Type, Card_Level,
			Card_Balance_Cashable_No, Card_Balance_Cashable, Card_PointAccumulate, 
			Card_isPinReset, Card_Point_Tier, Card_Point_Hidden, Card_img)
			VALUES (
			@strCardNumber,-9,@strMobileNumber,0,@strCreatedBy,GETDATE(),
			0,@strCompanyCode,@intPlayerID,0,@intCardType, @intCardType, 
			0,0,0,
			0,0,0,'')

			SELECT @intID = SCOPE_IDENTITY()
			set @CardId= SCOPE_IDENTITY();

		END
		
		

If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
