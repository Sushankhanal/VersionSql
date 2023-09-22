/****** Object:  Procedure [dbo].[sp_tblCounter_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblCounter_GetByStatus] (
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
				select ROW_NUMBER() OVER(ORDER BY Counter_Code)  AS RowNo
				from tblCounter (NOLOCK)
				where Counter_Code LIKE '%' + @strCode + '%' AND
					Counter_Name  LIKE '%' + @strName + '%' AND
					Counter_Status LIKE '%' + @strStatus + '%' AND
					Counter_CompanyCode = @strCompanyCode
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY Counter_Code)  AS RowNo,
				*, 
				(CASE Counter_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Counter_StatusText
				from tblCounter (NOLOCK)
				where Counter_Code LIKE '%' + @strCode + '%' AND
					Counter_Name  LIKE '%' + @strName + '%' AND
					Counter_Status LIKE '%' + @strStatus + '%'AND
					Counter_CompanyCode = @strCompanyCode
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by Counter_Code
	END
END
