/****** Object:  Procedure [dbo].[sp_tblPlayerLevel_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblPlayerLevel_GetByStatus '',-1,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblPlayerLevel_GetByStatus] (
	@strName	nvarchar(50),
	@intStatus			smallint,
	@strUserCode		nvarchar(50),
	@StartRecord INT,
	@EndRecord INT,
	@IsCount INT

) AS
BEGIN
	--Declare @strCompanyCode nvarchar(50)
	--select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

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
				select ROW_NUMBER() OVER(ORDER BY PlayerLevel_Sort)  AS RowNo
				from tblPlayerLevel (NOLOCK)
				where PlayerLevel_Name  LIKE '%' + @strName + '%' AND
					PlayerLevel_Status LIKE '%' + @strStatus + '%' 
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY PlayerLevel_Sort)  AS RowNo,
				*, 
				(CASE PlayerLevel_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as PlayerLevel_StatusText
				from tblPlayerLevel (NOLOCK)
				where PlayerLevel_Name  LIKE '%' + @strName + '%' AND
					PlayerLevel_Status LIKE '%' + @strStatus + '%'
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by PlayerLevel_Sort, PlayerLevel_Name
	END
END
