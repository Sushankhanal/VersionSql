/****** Object:  Procedure [dbo].[sp_rptPlayerRegistrationList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptTopPlayerRankingTurnOver '2018-06-01 09:00','2021-06-01 09:00','2,2',''
CREATE PROCEDURE [dbo].[sp_rptPlayerRegistrationList]
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

	select * from tblCardOwner CO (NOLOCK) 
	inner join tblPlayerLevel PL (NOLOCK) on PL.PlayerLevel_ID = CO.CardOwner_Level
	where CO.CardOwner_CreatedDate between @strStartDate and @strEndDate
	AND CO.CardOwner_Level IN (select a.PlayerLevelID from @tblTempPlayerLevel a)
	Order by CO.CardOwner_CreatedDate, CO.CardOwner_Name

	
END
