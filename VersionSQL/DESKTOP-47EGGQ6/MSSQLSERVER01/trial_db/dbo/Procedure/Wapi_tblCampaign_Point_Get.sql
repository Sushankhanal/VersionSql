/****** Object:  Procedure [dbo].[Wapi_tblCampaign_Point_Get]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Wapi_tblCampaign_Point_Get] (
	@intPointCampaignID	bigint = -1

)
 AS
BEGIN
	--Declare @strCompanyCode nvarchar(50)
	--select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

		select ROW_NUMBER() OVER(ORDER BY Campaign_Name)  AS RowNo,
				C.*, 
				(CASE Campaign_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Campaign_StatusText,
				dbo.fnCombineAllMachineString(@intPointCampaignID) as Campaign_MachineIDText
				from tblCampaign_Point (NOLOCK) C
				--where Campaign_Name  LIKE '%' + @strName + '%' AND
				--	Campaign_MachineName LIKE '%' + @strMachineName + '%' AND
				--	Campaign_Status LIKE '%' + @strStatus + '%' AND
				--	Campaign_StartDate >= @strDateFrom AND
				--	Campaign_EndDate <= @strDateTo
				where (CASE WHEN @intPointCampaignID = -1 THEN 1 ELSE CASE WHEN C.Campaign_ID = @intPointCampaignID THEN 1 ELSE 0 END END) > 0
				order by Campaign_Status

END
