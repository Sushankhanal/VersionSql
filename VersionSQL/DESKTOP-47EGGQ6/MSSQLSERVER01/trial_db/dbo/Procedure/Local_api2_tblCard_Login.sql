/****** Object:  Procedure [dbo].[Local_api2_tblCard_Login]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Local_api2_tblCard_Login]
	-- Add the parameters for the stored procedure here
	@strCardNumber	nvarchar(50),
	@strPassword	nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @strErrorText nvarchar(255) = ''
	Declare @intErrorCode int = 0

	if (select COUNT(Card_ID) from tblCard c (NOLOCK) where Card_SerialNo = @strCardNumber
	AND tblCard_pin = @strPassword) = 0
	BEGIN
		set @intErrorCode = -1
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Invalid card number or password.'
		--RAISERROR (@strErrorText,16,1);  
		--SET NOCOUNT OFF
		--Return @intErrorCode
	END
	else
	BEGIN
		set @intErrorCode = 1
		set @strErrorText = 'Success'
	END

    -- Insert statements for procedure here
	SELECT @intErrorCode as LoginStatus, @strErrorText as LoginStatusMsg
END
