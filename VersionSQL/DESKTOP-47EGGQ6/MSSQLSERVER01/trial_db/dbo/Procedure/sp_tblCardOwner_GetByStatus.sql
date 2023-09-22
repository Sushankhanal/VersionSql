/****** Object:  Procedure [dbo].[sp_tblCardOwner_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblCardOwner_GetByStatus] (
	@strName	nvarchar(50),
	@strIDNumber	nvarchar(50),
	@intStatus			smallint,
	@strUserCode		nvarchar(50),
	@intGender	smallint = -1,
	@intCountry	int = -1,
	@intLevel	int = -1,
	@strCardNumber nvarchar(50) = '',
	@intAgeFrom	int = 0,
	@intAgeTo	int = 99,
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
		if @strCardNumber = ''
		BEGIN
			SELECT COUNT(RowNo) AS intRowCount FROM
			(
				select ROW_NUMBER() OVER(ORDER BY CardOwner_ID)  AS RowNo
				from tblCardOwner CO (NOLOCK)
				left outer join tblCountry C on C.Country_ID = CO.CardOwner_Country_ID
				inner join tblPlayerLevel PL on PL.PlayerLevel_ID = CO.CardOwner_Level
				where CardOwner_Name LIKE '%' + @strName + '%' AND
				CardOwner_IC LIKE '%' + @strIDNumber + '%' AND
				(CASE WHEN @intGender = -1 THEN 1 ELSE CASE WHEN CardOwner_Gender = @intGender THEN 1 ELSE 0 END END) > 0 AND
				(CASE WHEN @intCountry = -1 THEN 1 ELSE CASE WHEN CardOwner_Country_ID = @intCountry THEN 1 ELSE 0 END END) > 0 AND
				(CASE WHEN @intLevel = -1 THEN 1 ELSE CASE WHEN CardOwner_Level = @intLevel THEN 1 ELSE 0 END END) > 0 AND
				(datediff(Y,YEAR(ISNULL(CardOwner_DOB,GETDATE())),year(GETDATE())) between @intAgeFrom and @intAgeTo) 
			)tblA
		END
		ELSE
		BEGIN
			SELECT COUNT(RowNo) AS intRowCount FROM
			(
				select ROW_NUMBER() OVER(ORDER BY CardOwner_ID)  AS RowNo
				from tblCardOwner CO (NOLOCK)
				left outer join tblCountry C on C.Country_ID = CO.CardOwner_Country_ID
				inner join tblPlayerLevel PL on PL.PlayerLevel_ID = CO.CardOwner_Level
				where CardOwner_Name LIKE '%' + @strName + '%' AND
				CardOwner_IC LIKE '%' + @strIDNumber + '%' AND
				(CASE WHEN @intGender = -1 THEN 1 ELSE CASE WHEN CardOwner_Gender = @intGender THEN 1 ELSE 0 END END) > 0 AND
				(CASE WHEN @intCountry = -1 THEN 1 ELSE CASE WHEN CardOwner_Country_ID = @intCountry THEN 1 ELSE 0 END END) > 0 AND
				(CASE WHEN @intLevel = -1 THEN 1 ELSE CASE WHEN CardOwner_Level = @intLevel THEN 1 ELSE 0 END END) > 0 AND
				(datediff(Y,YEAR(ISNULL(CardOwner_DOB,GETDATE())),year(GETDATE())) between @intAgeFrom and @intAgeTo) AND
				CO.CardOwner_ID IN (select Card_CardOwner_ID from tblCard where Card_SerialNo LIKE '%' + @strCardNumber + '%') 
			)tblA
		END

		
	END
ELSE
	BEGIN

		if @strCardNumber = ''
		BEGIN
			SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY CO.CardOwner_ID)  AS RowNo, CO.*, 
				ISNULL(C.Country_Name,'') as Country_Name,
				(CASE CardOwner_Gender WHEN 0 THEN 'Male' else 'Female' end) as CardOwner_GenderText,
				ISNULL(PL.PlayerLevel_Name,'') as PlayerLevel_Name,
				datediff(Y,YEAR(ISNULL(CardOwner_DOB,GETDATE())),year(GETDATE())) as PlayerAge,
				(CASE CardOwner_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as CardOwner_StatusText,
				ISNULL((Select SUM(Card_PointAccumulate) from tblCard where Card_CardOwner_ID = CO.CardOwner_ID),0) as AccumulatePoint
				from tblCardOwner CO (NOLOCK)
				left outer join tblCountry C on C.Country_ID = CO.CardOwner_Country_ID
				inner join tblPlayerLevel PL on PL.PlayerLevel_ID = CO.CardOwner_Level
				where CardOwner_Name LIKE '%' + @strName + '%' AND
				CardOwner_IC LIKE '%' + @strIDNumber + '%' AND
				(CASE WHEN @intGender = -1 THEN 1 ELSE CASE WHEN CardOwner_Gender = @intGender THEN 1 ELSE 0 END END) > 0 AND
				(CASE WHEN @intCountry = -1 THEN 1 ELSE CASE WHEN CardOwner_Country_ID = @intCountry THEN 1 ELSE 0 END END) > 0 AND
				(CASE WHEN @intLevel = -1 THEN 1 ELSE CASE WHEN CardOwner_Level = @intLevel THEN 1 ELSE 0 END END) > 0 AND
				(datediff(Y,YEAR(ISNULL(CardOwner_DOB,GETDATE())),year(GETDATE())) between @intAgeFrom and @intAgeTo) 
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by  LEN(CardOwner_Name), CardOwner_Name
		END
		ELSE
		BEGIN
			SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY CO.CardOwner_ID)  AS RowNo, CO.*, 
				ISNULL(C.Country_Name,'') as Country_Name,
				(CASE CardOwner_Gender WHEN 0 THEN 'Male' else 'Female' end) as CardOwner_GenderText,
				ISNULL(PL.PlayerLevel_Name,'') as PlayerLevel_Name,
				datediff(Y,YEAR(ISNULL(CardOwner_DOB,GETDATE())),year(GETDATE())) as PlayerAge,
				(CASE CardOwner_Status WHEN 00 THEN 'Active' ELSE 'Inactive' END) as CardOwner_StatusText,
				ISNULL((Select SUM(Card_PointAccumulate) from tblCard where Card_CardOwner_ID = CO.CardOwner_ID),0) as AccumulatePoint
				from tblCardOwner CO (NOLOCK)
				left outer join tblCountry C on C.Country_ID = CO.CardOwner_Country_ID
				inner join tblPlayerLevel PL on PL.PlayerLevel_ID = CO.CardOwner_Level
				where CardOwner_Name LIKE '%' + @strName + '%' AND
				CardOwner_IC LIKE '%' + @strIDNumber + '%' AND
				(CASE WHEN @intGender = -1 THEN 1 ELSE CASE WHEN CardOwner_Gender = @intGender THEN 1 ELSE 0 END END) > 0 AND
				(CASE WHEN @intCountry = -1 THEN 1 ELSE CASE WHEN CardOwner_Country_ID = @intCountry THEN 1 ELSE 0 END END) > 0 AND
				(CASE WHEN @intLevel = -1 THEN 1 ELSE CASE WHEN CardOwner_Level = @intLevel THEN 1 ELSE 0 END END) > 0 AND
				(datediff(Y,YEAR(ISNULL(CardOwner_DOB,GETDATE())),year(GETDATE())) between @intAgeFrom and @intAgeTo) AND
				CO.CardOwner_ID IN (select Card_CardOwner_ID from tblCard where Card_SerialNo LIKE '%' + @strCardNumber + '%') 
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by LEN(CardOwner_Name), CardOwner_Name
		END


		
	END
END
