/****** Object:  Procedure [dbo].[sp_tblCardType_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
Create PROCEDURE [dbo].[sp_tblCardType_GetByStatus] (
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
				select ROW_NUMBER() OVER(ORDER BY CardType_Name)  AS RowNo
				from tblCardType C (NOLOCK)
				where CardType_Name LIKE '%' + @strName + '%' AND
					 C.CardType_Status LIKE '%' + @strStatus + '%' 
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY CardType_Name)  AS RowNo,
				C.*, 
				(CASE CardType_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as CardType_StatusText
				from tblCardType C (NOLOCK)
				where CardType_Name LIKE '%' + @strName + '%' AND
					 C.CardType_Status LIKE '%' + @strStatus + '%' 
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
	END
END
