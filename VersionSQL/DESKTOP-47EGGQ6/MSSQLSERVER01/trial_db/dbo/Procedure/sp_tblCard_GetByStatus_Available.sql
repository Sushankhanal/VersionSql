/****** Object:  Procedure [dbo].[sp_tblCard_GetByStatus_Available]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblCard_GetByStatus_Available] (
	@strSerialNumber	nvarchar(50),
	@strName			nvarchar(50),
	@intStatus			smallint,
	@intCardType		smallint,
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
				select ROW_NUMBER() OVER(ORDER BY Card_SerialNo)  AS RowNo
				from tblCard C (NOLOCK)
				where Card_SerialNo LIKE '%' + @strSerialNumber + '%' AND
				Card_CardOwner_ID IS NULL AND Card_Status = 0
				AND C.Card_CompanyCode = @strCompanyCode
				AND
				(
				CASE WHEN @intCardType = -1 THEN 1 ELSE
				CASE WHEN Card_Type = @intCardType THEN 1 ELSE 0 END END
				) > 0
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY Card_SerialNo)  AS RowNo,
				C.*, 
				(CASE Card_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Card_StatusText,
				CT.CardType_Name
				from tblCard C (NOLOCK)
				inner join tblCardType CT on CT.CardType_ID = C.Card_Type
				where Card_SerialNo LIKE '%' + @strSerialNumber + '%' AND
				Card_CardOwner_ID IS NULL AND Card_Status = 0
				AND C.Card_CompanyCode = @strCompanyCode
				AND
				(
				CASE WHEN @intCardType = -1 THEN 1 ELSE
				CASE WHEN Card_Type = @intCardType THEN 1 ELSE 0 END END
				) > 0

			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by Card_Status, Card_SerialNo
	END
END
