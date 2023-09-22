/****** Object:  Procedure [dbo].[sp_tblTicket_Bonus_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblPlayerLevel_GetByStatus '',-1,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblTicket_Bonus_GetByStatus] (
	@strCode	nvarchar(50),
	@strName	nvarchar(50),
	@strCardNumber	nvarchar(50),
	@intStatus			smallint,
	@strDateFrom		datetime,
	@strDateTo			datetime,
	@StartRecord INT,
	@EndRecord INT,
	@IsCount INT

) AS
BEGIN
	--Declare @strCompanyCode nvarchar(50)
	--select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

	

	set @strDateTo = DATEADD(day,1,@strDateTo)
	set @strDateTo = DATEADD(second,-1,@strDateTo)

	--Declare @strStatus nvarchar(50)
	--set @strStatus = @intStatus
	--if @intStatus = -1
	--BEGIN
	--	set @strStatus = ''
	--END

	IF @IsCount = 1 
	BEGIN
		SELECT COUNT(RowNo) AS intRowCount FROM
			(
				select ROW_NUMBER() OVER(ORDER BY Ticket_Code)  AS RowNo
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
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
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

			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord

			
	END
END
