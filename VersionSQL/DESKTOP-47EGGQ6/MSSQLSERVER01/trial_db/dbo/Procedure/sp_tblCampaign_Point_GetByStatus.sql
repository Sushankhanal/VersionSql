/****** Object:  Procedure [dbo].[sp_tblCampaign_Point_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

Create PROCEDURE [dbo].[sp_tblCampaign_Point_GetByStatus] (
	@strName	nvarchar(50),
	@strMachineName	nvarchar(50),
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

	Declare @strStatus nvarchar(50)
	set @strStatus = @intStatus
	if @intStatus = -1
	BEGIN
		set @strStatus = ''
	END

	IF @IsCount = 1 
	BEGIN
		SELECT COUNT(RowNo) AS intRowCount FROM
			(
				select ROW_NUMBER() OVER(ORDER BY Campaign_Name)  AS RowNo
				from tblCampaign_Point (NOLOCK)
				where Campaign_Name  LIKE '%' + @strName + '%' AND
					Campaign_MachineName LIKE '%' + @strMachineName + '%' AND
					Campaign_Status LIKE '%' + @strStatus + '%' AND
					Campaign_StartDate >= @strDateFrom AND
					Campaign_EndDate <= @strDateTo
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY Campaign_Name)  AS RowNo,
				*, 
				(CASE Campaign_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Campaign_StatusText
				from tblCampaign_Point (NOLOCK)
				where Campaign_Name  LIKE '%' + @strName + '%' AND
					Campaign_MachineName LIKE '%' + @strMachineName + '%' AND
					Campaign_Status LIKE '%' + @strStatus + '%' AND
					Campaign_StartDate >= @strDateFrom AND
					Campaign_EndDate <= @strDateTo
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
	END
END
