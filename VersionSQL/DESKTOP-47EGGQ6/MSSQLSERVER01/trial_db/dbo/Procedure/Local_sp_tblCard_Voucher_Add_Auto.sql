/****** Object:  Procedure [dbo].[Local_sp_tblCard_Voucher_Add_Auto]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblCard_Voucher_Add_Auto 0 ,100,0,12,'Manager'
create PROCEDURE [dbo].[Local_sp_tblCard_Voucher_Add_Auto]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@dblValue	money,
	@intType	int,
	@intCardID	bigint,
	@strUsercode		nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Declare @strRandomNumber nvarchar(50)
		set @strRandomNumber = cast((9000000* Rand() + 10000000) as int )
		While (Select COUNT(CardVoucher_ID) from tblCard_Voucher (NOLOCK) where CardVoucher_Number = @strRandomNumber) > 0
		BEGIN
			SELECT @strRandomNumber =  cast((900000* Rand() + 10000000) as int )
		END

		Declare @dtExpiredDate datetime = DATEADD(YEAR,1, GETDATE())
		Declare @intCardOwnerID bigint = 0

		select @intCardOwnerID = C.Card_CardOwner_ID from tblCard C (NOLOCK) where Card_ID = @intCardID
		INSERT INTO tblCard_Voucher
		(CardVoucher_GenerateDate, CardVoucher_Number, CardVoucher_Value, CardVoucher_Type, CardVoucher_Status, 
		CardVoucher_Expired, CardVoucher_CardOwner_ID, CardVoucher_Card_ID, CardVoucher_CreatedBy, 
		CardVoucher_CreatedDate)
		VALUES (
		GETDATE(),@strRandomNumber,@dblValue,@intType,0,
		@dtExpiredDate,@intCardOwnerID,@intCardID,@strUsercode,
		GETDATE())
		SELECT @ID = SCOPE_IDENTITY()

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
