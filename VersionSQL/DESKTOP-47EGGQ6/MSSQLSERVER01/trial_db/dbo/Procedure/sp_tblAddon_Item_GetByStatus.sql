/****** Object:  Procedure [dbo].[sp_tblAddon_Item_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblAddon_Item_GetByStatus] (
	@strItemCode	nvarchar(50),
	@strItemName	nvarchar(50),
	@intStatus			smallint,
	@strUserCode		nvarchar(50),
	@StartRecord INT,
	@EndRecord INT,
	@IsCount INT

) AS
BEGIN
	set @EndRecord = 999

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
				select ROW_NUMBER() OVER(ORDER BY Addon_ItemCode)  AS RowNo
				from tblAddon_Item (NOLOCK)
				where Addon_ItemCode LIKE '%' + @strItemCode + '%' AND
					Addon_Desc  LIKE '%' + @strItemName + '%' AND
					Addon_Status LIKE '%' + @strStatus + '%' AND
					Addon_CompanyCode = @strCompanyCode
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY Addon_ItemCode)  AS RowNo,
				*, 
				(CASE Addon_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as AddOn_StatusText
				from tblAddon_Item (NOLOCK)
				where Addon_ItemCode LIKE '%' + @strItemCode + '%' AND
					Addon_Desc  LIKE '%' + @strItemName + '%' AND
					Addon_Status LIKE '%' + @strStatus + '%'AND
					Addon_CompanyCode = @strCompanyCode
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by Addon_ItemCode
	END
END
