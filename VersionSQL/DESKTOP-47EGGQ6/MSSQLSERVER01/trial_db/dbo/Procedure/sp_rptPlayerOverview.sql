/****** Object:  Procedure [dbo].[sp_rptPlayerOverview]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptPlayerPointMovementReport '2020-06-01 09:00','2020-06-01 09:00',2
CREATE PROCEDURE [dbo].[sp_rptPlayerOverview]
	-- Add the parameters for the stored procedure here
	@strStartDate	datetime,
	@strEndDate		datetime,
	@intPlayerID	bigint,
	@strLocation	nvarchar(50),
	@strCurrency	nvarchar(50),
	@strStartSessionTime	nvarchar(50),
	@strUserCode			nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @strEndDate = DATEADD(day,1,@strEndDate)
	--set @strEndDate = DATEADD(second,-1,@strEndDate)
	
	Declare @strOwnderName nvarchar(50) = ''
	select @strOwnderName = CardOwner_Name from tblCardOwner where CardOwner_ID = 5-- @intPlayerID

	select
	(CASE WHEN dbo.fnGetDiffTime(cast(convert(char(5), CardPointTrans_CreatedDate, 108) as time),cast(@strStartSessionTime as time)) >= 0 
	THEN CAST(CardPointTrans_CreatedDate as date)
	ELSE CAST(DATEADD(day,-1,CardPointTrans_CreatedDate) as date) END) 
	as SessionDate, T.CardPointTrans_CreatedDate, ISNULL(M.Machine_Name,'') as Machine_Name,
	CardPointTrans_MoneyIn, CardPointTrans_MoneyOut, 0 as JP, T.CardPointTrans_SerialNo, 
	(CardPointTrans_MoneyIn - CardPointTrans_MoneyOut) as WinLoss, 
	(CASE WHEN CardPointTrans_MoneyIn = 0 THEN 0 ELSE (CardPointTrans_MoneyOut/CardPointTrans_MoneyIn) END) as RTP, T.CardPointTrans_PointValue,
	@strOwnderName as OwnerName, @strLocation as LocationName, @strCurrency as CurrencyName, @strUserCode as PrintBy
	from tblCardPointTrans T (NOLOCK) 
	left outer join tblMachine M (NOLOCK) on M.Machine_ID = T.CardPointTrans_MachineID
	where T.CardPointTrans_CreatedDate between @strStartDate and @strEndDate
	and T.CardPointTrans_SerialNo in (select C.Card_SerialNo from tblCard C (NOLOCK) where C.Card_CardOwner_ID = @intPlayerID)
	Order by T.CardPointTrans_CreatedDate desc, M.Machine_Name

   
END
