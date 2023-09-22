/****** Object:  Procedure [dbo].[sp_rptTopPlayerRankingTurnOver]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptTopPlayerRankingTurnOver '2018-06-01 09:00','2021-06-01 09:00','2,2',''
CREATE PROCEDURE [dbo].[sp_rptTopPlayerRankingTurnOver]
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
	--set @strEndDate = DATEADD(day,1,@strEndDate)
	--set @strEndDate = DATEADD(second,-1,@strEndDate)
	
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

	select top 100 ROW_NUMBER() OVER(ORDER BY SUM(CardPointTrans_Turnover) Desc)  AS RowNo,
	CO.CardOwner_Name, PL.PlayerLevel_Name,
	SUM(CardPointTrans_PointEarned) as PointEarned, 0 as PointsRedeemed, COUNT(CardPointTrans_ID) as TotalVisits, 
	SUM(CardPointTrans_GamePlayed) as TotalGamePlayed, 
	(SUM(CardPointTrans_GamePlayed)/COUNT(CardPointTrans_ID)) as GpPerVisit, 
	SUM(CardPointTrans_Turnover) as Turnover,
	(CASE WHEN SUM(CardPointTrans_GamePlayed) = 0 THEN 0 ELSE SUM(CardPointTrans_Turnover)/SUM(CardPointTrans_GamePlayed) END) as TurnoverPerGame, 
	( SUM(CardPointTrans_Turnover)/COUNT(CardPointTrans_ID)) as TurnoverPerVisit,
	SUM(T.CardPointTrans_MoneyOut) as TotalOut, SUM(CardPointTrans_Won) as WinLoss 
	from tblCardPointTrans T (NOLOCK) 
	inner join tblCard C (NOLOCK) on C.Card_SerialNo = T.CardPointTrans_SerialNo
	inner join tblCardOwner CO (NOLOCK) on CO.CardOwner_ID = C.Card_CardOwner_ID  
	inner join tblPlayerLevel PL (NOLOCK) on PL.PlayerLevel_ID = CO.CardOwner_Level
	where T.CardPointTrans_CreatedDate between @strStartDate and @strEndDate
	AND PL.PlayerLevel_ID IN (select a.PlayerLevelID from @tblTempPlayerLevel a)
	AND CO.CardOwner_Level IN (select a.PlayerLevelID from @tblTempPlayerLevel a)
	Group by CO.CardOwner_Name, PL.PlayerLevel_Name
	Order by SUM(CardPointTrans_Turnover) desc

   
END
