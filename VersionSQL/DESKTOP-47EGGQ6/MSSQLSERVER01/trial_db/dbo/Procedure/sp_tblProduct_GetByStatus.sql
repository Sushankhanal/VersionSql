/****** Object:  Procedure [dbo].[sp_tblProduct_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblProduct_GetByStatus] (
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
				select ROW_NUMBER() OVER(ORDER BY Product_ItemCode)  AS RowNo
				from tblProduct (NOLOCK)
				where Product_ItemCode LIKE '%' + @strCategoryCode + '%' AND
					Product_Desc  LIKE '%' + @strCategoryName + '%' AND
					Product_Status LIKE '%' + @strStatus + '%'
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY Product_ItemCode)  AS RowNo,
				*, 
				(CASE Product_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Product_StatusText
				from tblProduct (NOLOCK)
				where Product_ItemCode LIKE '%' + @strCategoryCode + '%' AND
					Product_Desc  LIKE '%' + @strCategoryName + '%' AND
					Product_Status LIKE '%' + @strStatus + '%'
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by Product_ItemCode
	END
END
