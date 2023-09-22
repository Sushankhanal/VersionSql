/****** Object:  Procedure [dbo].[sp_rptInactivePlayer]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptInactivePlayer 1,'',''
CREATE PROCEDURE [dbo].[sp_rptInactivePlayer]
	-- Add the parameters for the stored procedure here
	@strInactivePeriod	int,
	@strPlayerLevel	nvarchar(500),
	@strUserCode	nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	set @strInactivePeriod = 0 - @strInactivePeriod
	Declare @strTodayDate date = GETDATE()
	Declare @strStartDate datetime = DATEADD(day,@strInactivePeriod,@strTodayDate)
	Declare @strEndDate datetime  = GETDATE()

	set @strEndDate = DATEADD(day,1,@strEndDate)
	set @strEndDate = DATEADD(second,-1,@strEndDate)
	
	DECLARE @tblTempPlayerLevel TABLE
    (PlayerLevelID INT, PlayerLevelName nvarchar(50), IsProcess INT)
	
	if @strPlayerLevel = ''
	BEGIN
		insert into @tblTempPlayerLevel
		select PlayerLevel_ID, PlayerLevel_Name, 0 from tblPlayerLevel B (NOLOCK) where B.PlayerLevel_Status = 0 
		Order by B.PlayerLevel_Name
	END
	ELSE
	BEGIN
		insert into @tblTempPlayerLevel
		select PlayerLevel_ID, PlayerLevel_Name, 0 from tblPlayerLevel B (NOLOCK) where B.PlayerLevel_Status = 0 
		AND  PlayerLevel_ID in (select Name from dbo.fnSplitstringToTable(@strPlayerLevel))
		Order by B.PlayerLevel_Name
	END
	--select * from @tblTempPlayerLevel

	Select CO.CardOwner_Name, PL.PlayerLevel_Name, CO.CardOwner_CreatedDate,
	dbo.fnGetPlayerLastGameDate(CO.CardOwner_ID) as LastPlayDate,
	ISNULL(SUM(C.Card_Point),0) as RedeemedPoints
	from tblCard C (NOLOCK)
	inner join tblCardOwner CO (NOLOCK) on CO.CardOwner_ID = C.Card_CardOwner_ID
	inner join tblPlayerLevel PL (NOLOCK) on PL.PlayerLevel_ID = CO.CardOwner_Level
	where C.Card_SerialNo not in (
	select T.CardPointTrans_SerialNo from tblCardPointTrans T (NOLOCK) 
	where T.CardPointTrans_CreatedDate between @strStartDate and @strEndDate
	Group by T.CardPointTrans_SerialNo
	)
	AND CO.CardOwner_Level IN (select a.PlayerLevelID from @tblTempPlayerLevel a)
	Group by CO.CardOwner_Name, PL.PlayerLevel_Name, CO.CardOwner_CreatedDate, dbo.fnGetPlayerLastGameDate(CO.CardOwner_ID)
	
END
