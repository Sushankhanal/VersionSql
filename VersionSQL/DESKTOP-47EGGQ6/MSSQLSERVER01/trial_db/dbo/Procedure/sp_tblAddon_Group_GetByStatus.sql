/****** Object:  Procedure [dbo].[sp_tblAddon_Group_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblAddon_Group_GetByStatus] (
	@strCode	nvarchar(50),
	@strName	nvarchar(50),
	@intStatus			smallint,
	@strUserCode		nvarchar(50),
	@StartRecord INT,
	@EndRecord INT,
	@IsCount INT

) AS
BEGIN
	Declare @strCompanyCode nvarchar(50)
	select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

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
				select ROW_NUMBER() OVER(ORDER BY AddonGroup_Code)  AS RowNo
				from tblAddon_Group (NOLOCK)
				where AddonGroup_Code LIKE '%' + @strCode + '%' AND
					AddonGroup_Desc  LIKE '%' + @strName + '%' AND
					AddonGroup_Status LIKE '%' + @strStatus + '%' AND
					AddonGroup_CompanyCode = @strCompanyCode
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY AddonGroup_Code)  AS RowNo,
				*, 
				(CASE AddonGroup_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as AddonGroup_StatusText
				from tblAddon_Group (NOLOCK)
				where AddonGroup_Code LIKE '%' + @strCode + '%' AND
					AddonGroup_Desc  LIKE '%' + @strName + '%' AND
					AddonGroup_Status LIKE '%' + @strStatus + '%' AND
					AddonGroup_CompanyCode = @strCompanyCode
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by AddonGroup_Code
	END
END
