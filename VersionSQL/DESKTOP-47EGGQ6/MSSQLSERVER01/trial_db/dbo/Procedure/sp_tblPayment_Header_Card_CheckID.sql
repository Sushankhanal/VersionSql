/****** Object:  Procedure [dbo].[sp_tblPayment_Header_Card_CheckID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Header_Card_CheckID 1
CREATE PROCEDURE [dbo].[sp_tblPayment_Header_Card_CheckID]
	-- Add the parameters for the stored procedure here
	@intSyncLocalID				bigint,
	@strReceiptNo				nvarchar(50) OUT,
	@strClientFullName			nvarchar(50) OUT,
	@strClientBalance			money OUT,
	@strClientPoint				decimal(38, 10) OUT,
	@dblClientBalanceCashableNo	money OUT,
	@dblClientBalanceCashable	money OUT,
	@dblClientPointAccumulate	decimal(38, 10) OUT,
	@dblClientPointTier			decimal(38, 10) OUT,
	@dblClientPointHidden		decimal(38, 10) OUT
	
AS
BEGIN
	
	SET NOCOUNT ON;

	set @strReceiptNo = ''
	set @strClientFullName = ''
	set @strClientBalance = 0
	set @strClientPoint = 0

	set @dblClientBalanceCashableNo = 0
	set @dblClientBalanceCashable = 0
	set @dblClientPointAccumulate = 0
	set @dblClientPointTier = 0
	set @dblClientPointHidden = 0

	IF (select COUNT(H.Payment_ID) from tblPayment_Header H (NOLOCK) where Payment_SyncLocalID = @intSyncLocalID) <> 0
	BEGIN
		select @strReceiptNo = Payment_ReceiptNo from tblPayment_Header H (NOLOCK) where H.Payment_SyncLocalID = @intSyncLocalID
		select @strClientFullName = Card_SerialNo, @strClientBalance = Card_Balance, @strClientPoint = Card_Point,
		@dblClientBalanceCashableNo = Card_Balance_Cashable_No ,
		@dblClientBalanceCashable = Card_Balance_Cashable,
		@dblClientPointAccumulate = Card_PointAccumulate,
		@dblClientPointTier = Card_Point_Tier,
		@dblClientPointHidden = Card_Point_Hidden  from tblPayment_Header H (NOLOCK) 
		inner join tblCard C (NOLOCK) on C.Card_SerialNo = H.Payment_UserCode
		where Payment_SyncLocalID = 1
	END
	
	RETURN (0)
	
END
