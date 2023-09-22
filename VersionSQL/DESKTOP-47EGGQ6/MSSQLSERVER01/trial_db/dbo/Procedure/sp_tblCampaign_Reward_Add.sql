/****** Object:  Procedure [dbo].[sp_tblCampaign_Reward_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCampaign_Reward_Add]
	-- Add the parameters for the stored procedure here
	@ID				int OUT,
	@intTypeID		int,
	@strName		nvarchar(50),
	@strStartDate	datetime,
	@strEndDate		datetime,
	@dblCreditCashable		money,
	@dblCreditCashableNo		money,
	@intMaxQty		int,
	@intExpiryDay	int,	
	@strRemarks		nvarchar(500),
	@intStatus		smallint,
	@intCardType	int,
	@strUsercode	nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		
		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(Reward_ID), 0) FROM tblCampaign_Reward NOLOCK WHERE (Reward_Name = @strName )
		
		IF @intCount = 0 
		BEGIN
			INSERT INTO tblCampaign_Reward
			(Reward_Type_ID, Reward_Name, Reward_StartDate, Reward_EndDate, 
			Reward_CreditCashable, Reward_CreditNonCashable,Reward_MaxQty,
			Reward_ExpiryDay, Reward_Status, Reward_Remarks, 
			Reward_CardType, Reward_CreatedBy, Reward_CreatedDate, Reward_UpdatedBy, Reward_UpdatedDate)
			VALUES (
			@intTypeID,@strName,@strStartDate,@strEndDate,
			@dblCreditCashable,@dblCreditCashableNo , @intMaxQty, 
			@intExpiryDay, @intStatus, @strRemarks,
			@intCardType,@strUsercode,GETDATE(),@strUsercode,GETDATE())
			SELECT @ID = SCOPE_IDENTITY()

		END
		ELSE
		BEGIN
			set @ID = 0
			RAISERROR ('Error: Campaign name already used, Please try another name.',16,1);  
			Rollback TRANSACTION
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
