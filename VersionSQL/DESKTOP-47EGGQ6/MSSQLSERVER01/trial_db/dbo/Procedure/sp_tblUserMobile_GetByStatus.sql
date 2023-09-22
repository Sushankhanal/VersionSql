/****** Object:  Procedure [dbo].[sp_tblUserMobile_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblUserMobile_GetByStatus] (
	@strMobileUserCode	nvarchar(50),
	@strName			nvarchar(50),
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
				select ROW_NUMBER() OVER(ORDER BY mUser_Code)  AS RowNo
				from tblUserMobile (NOLOCK)
				where mUser_Code LIKE '%' + @strMobileUserCode + '%' AND
					mUser_FullName  LIKE '%' + @strName + '%' AND
					mUser_Status LIKE '%' + @strStatus + '%' AND
					mUser_CompanyCode = @strCompanyCode
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY mUser_Code)  AS RowNo,
				*, 
				(CASE mUser_Status WHEN 1 THEN 'Active' ELSE 'Inactive' END) as mUser_StatusText
				from tblUserMobile (NOLOCK)
				where mUser_Code LIKE '%' + @strMobileUserCode + '%' AND
					mUser_FullName  LIKE '%' + @strName + '%' AND
					mUser_Status LIKE '%' + @strStatus + '%' AND
					mUser_CompanyCode = @strCompanyCode
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by mUser_Code
	END
END
