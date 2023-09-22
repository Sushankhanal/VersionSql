/****** Object:  Procedure [dbo].[api2_tblCard_Trans_Check]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[api2_tblCard_Trans_Check]
	-- Add the parameters for the stored procedure here
	@strUniqueKey	nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @strErrorText nvarchar(255) = ''
	Declare @intErrorCode int = 0


	if (select COUNT(t.CardTrans_ID) from tblCard_Trans t (NOLOCK) where CardTrans_APIKey = @strUniqueKey) = 0
	BEGIN
		set @intErrorCode = -1
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Unique Key Records not found.'
		RAISERROR (@strErrorText,16,1);  
		SET NOCOUNT OFF
		Return @intErrorCode
	END

	 Declare @strCardNumber nvarchar(50) = ''
	select  @strCardNumber = t.CardTrans_SerialNo from tblCard_Trans t (NOLOCK) where CardTrans_APIKey = @strUniqueKey

    Declare @dblCardBalance money = 0
	select @dblCardBalance = Card_Balance from tblCard c (NOLOCK) where Card_SerialNo = @strCardNumber

	SELECT t.CardTrans_Code as ReceiptNo, 1 as TransStatus, @dblCardBalance as CardBalance 
	from tblCard_Trans t (NOLOCK) where CardTrans_APIKey = @strUniqueKey

END
