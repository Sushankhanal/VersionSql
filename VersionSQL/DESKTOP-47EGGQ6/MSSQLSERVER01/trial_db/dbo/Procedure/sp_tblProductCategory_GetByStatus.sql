/****** Object:  Procedure [dbo].[sp_tblProductCategory_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblProductCategory_GetByStatus] (
	@strCategoryCode	nvarchar(50),
	@strCategoryName	nvarchar(50),
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
				select ROW_NUMBER() OVER(ORDER BY ProCategory_Code)  AS RowNo
				from tblProductCategory (NOLOCK)
				where ProCategory_Code LIKE '%' + @strCategoryCode + '%' AND
					ProCategory_Name  LIKE '%' + @strCategoryName + '%' AND
					ProCategory_Status LIKE '%' + @strStatus + '%' AND
					ProCategory_CompanyCode = @strCompanyCode
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY ProCategory_Code)  AS RowNo,
				*, 
				(CASE ProCategory_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as ProCategory_StatusText
				from tblProductCategory (NOLOCK)
				where ProCategory_Code LIKE '%' + @strCategoryCode + '%' AND
					ProCategory_Name  LIKE '%' + @strCategoryName + '%' AND
					ProCategory_Status LIKE '%' + @strStatus + '%'AND
					ProCategory_CompanyCode = @strCompanyCode
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by ProCategory_ID
	END
END
