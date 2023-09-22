/****** Object:  Procedure [dbo].[Wapi_tblTicket_Bonus_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

Create PROCEDURE [dbo].[Wapi_tblTicket_Bonus_GetByStatus] (
	@strCode	nvarchar(50),
	@strName	nvarchar(50),
	@strCardNumber	nvarchar(50),
	@intStatus			smallint,
	@strDateFrom		datetime,
	@strDateTo			datetime

) AS
BEGIN
	
	set @strDateTo = DATEADD(day,1,@strDateTo)
	set @strDateTo = DATEADD(second,-1,@strDateTo)

	
	select ROW_NUMBER() OVER(ORDER BY Ticket_Code)  AS RowNo, T.* ,
					(CASE Ticket_Status WHEN 0 THEN 'New' ELSE 'Redeemed' END) as Ticket_StatusText,
					mUser_FullName, P.Campaign_Name
					from tblTicket_Bonus T (NOLOCK)
					left outer join tblUserMobile M (NOLOCK) on M.mUser_Code = T.Ticket_UserCode
					inner join tblCampaign_Point P (NOLOCK) on P.Campaign_ID = T.Ticket_CampaignID
					where Ticket_Code LIKE '%' + @strCode + '%'
					AND Ticket_SerialNumber LIKE '%' + @strCardNumber + '%'
					AND Ticket_TransDate between @strDateFrom and @strDateTo
					AND Ticket_Status = @intStatus
					AND ISNULL(M.mUser_FullName,'') LIKE '%' + @strName + '%'
					AND Ticket_TransDate >= @strDateFrom AND
					Ticket_TransDate <= @strDateTo
END
