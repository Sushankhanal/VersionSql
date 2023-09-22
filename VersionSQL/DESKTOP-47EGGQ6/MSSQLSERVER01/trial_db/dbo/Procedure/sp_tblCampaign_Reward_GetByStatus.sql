/****** Object:  Procedure [dbo].[sp_tblCampaign_Reward_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblCampaign_Reward_GetByStatus] (
	@strName	nvarchar(50),
	@intCardType	bigint,
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

	
	IF @IsCount = 1 
	BEGIN
		SELECT COUNT(RowNo) AS intRowCount FROM
			(
				select ROW_NUMBER() OVER(ORDER BY Reward_Name)  AS RowNo
				from tblCampaign_Reward (NOLOCK)
				where Reward_Name  LIKE '%' + @strName + '%' AND
					Reward_StartDate >= @strDateFrom AND
					Reward_EndDate <= @strDateTo AND
					(CASE WHEN @intStatus = -1 THEN 1 ELSE CASE WHEN Reward_Status = @intStatus THEN 1 ELSE 0 END END) > 0 AND
					(CASE WHEN @intCardType = -1 THEN 1 ELSE CASE WHEN Reward_CardType = @intCardType THEN 1 ELSE 0 END END) > 0 
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY Reward_Name)  AS RowNo,
				R.*, 
				(CASE Reward_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Reward_StatusText,
				ISNULL(C.CardType_Name,'') as CardType_Name,
				(CASE Reward_Type_ID WHEN 1 THEN 'WELCOME BONUS' ELSE 'Unknown' END) as Reward_Type_Text
				from tblCampaign_Reward R (NOLOCK)
				left outer join tblCardType C (NOLOCK) on C.CardType_ID = R.Reward_CardType
				where Reward_Name  LIKE '%' + @strName + '%' AND
					Reward_StartDate >= @strDateFrom AND
					Reward_EndDate <= @strDateTo AND
					(CASE WHEN @intStatus = -1 THEN 1 ELSE CASE WHEN Reward_Status = @intStatus THEN 1 ELSE 0 END END) > 0 AND
					(CASE WHEN @intCardType = -1 THEN 1 ELSE CASE WHEN Reward_CardType = @intCardType THEN 1 ELSE 0 END END) > 0 
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
	END
END
