/****** Object:  Procedure [dbo].[sp_rptPlayerHeadCount]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptPlayerHeadCount '2018-06-01 09:00','2021-06-01 09:00','',''
CREATE PROCEDURE [dbo].[sp_rptPlayerHeadCount]
	-- Add the parameters for the stored procedure here
	@strStartDate	datetime,
	@strEndDate		datetime,
	@strPlayerLevel	nvarchar(500),
	@strUserCode	nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
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

	DECLARE @tblSummary TABLE
    (PlayerLevelID INT, PlayerLevelName nvarchar(50), TotalCheckIn bigint, TotalIn money, TotalOut money, TotalTurnover money)

	insert into @tblSummary
	select PL.PlayerLevel_ID, PL.PlayerLevel_Name, COUNT(CardPointTrans_ID) as TotalCheckIn,
	SUM(T.CardPointTrans_MoneyIn) as TotalIn, SUM(T.CardPointTrans_MoneyOut) as TotalOut, 
	SUM(CardPointTrans_Turnover) as TotalTurnover
	from tblCardPointTrans T (NOLOCK) 
	inner join tblCard C (NOLOCK) on C.Card_SerialNo = T.CardPointTrans_SerialNo
	inner join tblCardOwner CO (NOLOCK) on CO.CardOwner_ID = C.Card_CardOwner_ID
	inner join tblPlayerLevel PL (NOLOCK) on PL.PlayerLevel_ID = CO.CardOwner_Level
	where T.CardPointTrans_CreatedDate between @strStartDate and @strEndDate
	AND PL.PlayerLevel_ID IN (select a.PlayerLevelID from @tblTempPlayerLevel a)
	AND CO.CardOwner_Level IN (select a.PlayerLevelID from @tblTempPlayerLevel a)
	Group by PL.PlayerLevel_Name, PL.PlayerLevel_ID


	select PL.PlayerLevel_ID, PL.PlayerLevel_Name, 
	ISNULL(S.TotalCheckIn,0) as TotalCheckIn, 
	ISNULL(S.TotalIn,0) as TotalIn, 
	ISNULL(S.TotalOut,0) as TotalOut, 
	ISNULL(S.TotalTurnover,0) as TotalTurnover 
	from tblPlayerLevel PL (NOLOCK) 
	left outer join @tblSummary S on S.PlayerLevelID = PL.PlayerLevel_ID
	where PL.PlayerLevel_ID IN (select a.PlayerLevelID from @tblTempPlayerLevel a)
	Order by PL.PlayerLevel_Sort, PL.PlayerLevel_ID
	
END
