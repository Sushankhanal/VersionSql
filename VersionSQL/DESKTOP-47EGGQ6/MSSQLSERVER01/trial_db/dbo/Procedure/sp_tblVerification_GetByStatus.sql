/****** Object:  Procedure [dbo].[sp_tblVerification_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblVerification_GetByStatus '','',0,0,100,0
Create PROCEDURE [dbo].[sp_tblVerification_GetByStatus] (
	@strMobileNumber	nvarchar(50),
	@intVerify			smallint,
	@strUserCode		nvarchar(50),
	@StartRecord INT,
	@EndRecord INT,
	@IsCount INT

) AS
BEGIN

	Declare @strStatus nvarchar(50)
	set @strStatus = @intVerify
	if @intVerify = -1
	BEGIN
		set @strStatus = ''
	END

	IF @IsCount = 1 
	BEGIN
		SELECT COUNT(RowNo) AS intRowCount FROM
			(
				select ROW_NUMBER() OVER(ORDER BY verification_code)  AS RowNo
				from verification (NOLOCK)
				where verification_mobileno LIKE '%' + @strMobileNumber + '%' AND
					verification_verify LIKE '%' + @strStatus + '%' 

			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY verification_code)  AS RowNo,
				*, 
				(CASE verification_verify WHEN 1 THEN 'Yes' ELSE 'No' END) as StatusVerify
				from verification (NOLOCK)
				where verification_mobileno LIKE '%' + @strMobileNumber + '%' AND
					verification_verify LIKE '%' + @strStatus + '%' 
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by verification_createdon desc
	END
END
