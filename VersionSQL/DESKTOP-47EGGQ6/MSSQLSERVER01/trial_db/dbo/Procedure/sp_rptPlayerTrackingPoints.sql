/****** Object:  Procedure [dbo].[sp_rptPlayerTrackingPoints]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptInactivePlayer 1,'',''
CREATE PROCEDURE [dbo].[sp_rptPlayerTrackingPoints]
	-- Add the parameters for the stored procedure here
	@strPlayerLevel	nvarchar(500),
	@strUserCode	nvarchar(50),
	@intGender		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
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

	select CO.CardOwner_ID, CO.CardOwner_Name, 
	(CASE WHEN CO.CardOwner_Gender = 0 THEN 'Male' ELSE 'Female'  END) as strGender,
	CO.CardOwner_IC, PL.PlayerLevel_Name, 
	dbo.fnGetPlayerLastGameDate(CO.CardOwner_ID) as LastPlayDate,
	ISNULL((select SUM(C.Card_Point) from tblCard C (NOLOCK) where C.Card_CardOwner_ID = CO.CardOwner_ID),0) as LifePoints,
	CO.CardOwner_DOB, DateDiff(year,CO.CardOwner_DOB,GETDATE()) as PlayerAge
	from tblCardOwner CO (NOLOCK)
	inner join tblPlayerLevel PL (NOLOCK) on PL.PlayerLevel_ID = CO.CardOwner_Level
	where (CASE WHEN @intGender = -1  THEN 1 ELSE CASE WHEN CO.CardOwner_Gender = @intGender THEN 1 ELSE 0 END END)> 0
	AND PL.PlayerLevel_ID IN (select a.PlayerLevelID from @tblTempPlayerLevel a)
	AND CO.CardOwner_Level IN (select a.PlayerLevelID from @tblTempPlayerLevel a)
END
