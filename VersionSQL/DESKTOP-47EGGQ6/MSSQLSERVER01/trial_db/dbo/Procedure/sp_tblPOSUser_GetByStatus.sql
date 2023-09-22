/****** Object:  Procedure [dbo].[sp_tblPOSUser_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblPOSUser_GetByStatus] (
	@strName			nvarchar(50),
	@intStatus			smallint,
	@strUserCode		nvarchar(50),
	@strCompanyCode     nvarchar(50),
	@intUserGroup			smallint,
	@intUserType			smallint,
	@StartRecord		INT,
	@EndRecord			INT,
	@IsCount			INT

) AS
BEGIN
	--Declare @strCompanyCode nvarchar(50)
	--select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

	--Declare @strStatus nvarchar(50)
	--set @strStatus = @intStatus
	--if @intStatus = -1
	--BEGIN
	--	set @strStatus = ''
	--END

	Declare @strUGroup nvarchar(50)
	set @strUGroup = @intUserGroup
	if @intUserGroup = -1
	BEGIN
		set @strUGroup = ''
	END

	Declare @companyCode nvarchar(50)
	set @companyCode = @strCompanyCode
	if @strCompanyCode = '-1'
	BEGIN
		set @companyCode = ''
	END

	IF @IsCount = 1 
	BEGIN
		SELECT COUNT(RowNo) AS intRowCount FROM
			(
				select ROW_NUMBER() OVER(ORDER BY POSUser_Code)  AS RowNo
				from tblPOSUser (NOLOCK)
				inner join tblCompany (NOLOCK) ON tblPOSUser.POSUser_CompanyCode = tblCompany.Company_Code
				--inner join tblUser_GroupMaster (NOLOCK)  ON tblPOSUser.POSUser_UserGroupID = tblUser_GroupMaster.UGroup_ID
				where POSUser_Name  LIKE '%' + @strName + '%' AND
					--POSUser_Status LIKE '%' + @strStatus + '%' AND
					POSUser_CompanyCode LIKE '%' + @companyCode + '%' AND
					POSUser_UserGroupID LIKE '%' + @strUGroup + '%' 
					AND POSUser_UserType =  @intUserType
					AND (CASE WHEN @intStatus = -1 THEN 1 ELSE CASE WHEN POSUser_Status = @intStatus THEN 1 ELSE 0 END END) > 0
			)tblA
	END
	ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY POSUser_Code)  AS RowNo,
				*, 
				(CASE POSUser_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as POSUser_StatusText
				from tblPOSUser (NOLOCK)
				inner join tblCompany (NOLOCK) ON tblPOSUser.POSUser_CompanyCode = tblCompany.Company_Code
				--inner join tblUser_GroupMaster (NOLOCK)  ON tblPOSUser.POSUser_UserGroupID = tblUser_GroupMaster.UGroup_ID
				where POSUser_Name  LIKE '%' + @strName + '%' AND
					--POSUser_Status LIKE '%' + @strStatus + '%' AND
					POSUser_CompanyCode LIKE '%' + @companyCode + '%' AND
					POSUser_UserGroupID LIKE '%' + @strUGroup + '%'
					AND POSUser_UserType =  @intUserType
					AND (CASE WHEN @intStatus = -1 THEN 1 ELSE CASE WHEN POSUser_Status = @intStatus THEN 1 ELSE 0 END END) > 0
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by POSUser_Code
	END
END
