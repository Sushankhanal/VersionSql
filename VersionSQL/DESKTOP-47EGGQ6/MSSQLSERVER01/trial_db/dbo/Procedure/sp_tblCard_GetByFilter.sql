/****** Object:  Procedure [dbo].[sp_tblCard_GetByFilter]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblCard_GetByFilter] (
	@intAgeFrom			int,
	@intAgeTo			int,
	@intGender	int,
	@intPointFrom	int,
	@intPointTo int,
	@intPointFrom_Tier	int,
	@intPointTo_Tier int,
	@intPointFrom_Hidden	int,
	@intPointTo_Hidden int,
	@intPointFrom_Acc	int,
	@intPointTo_Acc int,
	@strUserCode nvarchar(50),
	@StartRecord INT,
	@EndRecord INT,
	@IsCount INT
		
	
) AS
BEGIN
	Declare @strCompanyCode nvarchar(50)
	select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode


	IF @IsCount = 1 
	BEGIN
		SELECT COUNT(RowNo) AS intRowCount FROM
			(
				select ROW_NUMBER() OVER(ORDER BY CO.CardOwner_ID)  AS RowNo
				from tblCardOwner CO (NOLOCK)
				inner join tblPlayerLevel PL on PL.PlayerLevel_ID = CO.CardOwner_Level
				inner join tblCard C (NOLOCK) on C.Card_CardOwner_ID = CO.CardOwner_ID
				where (DATEDIFF(YEAR, CO.CardOwner_DOB, GETDATE()) between @intAgeFrom and  @intAgeTo)
				AND (
				CASE WHEN @intGender = -1 THEN 1 ELSE
				CASE WHEN CO.CardOwner_Gender = @intGender THEN 1 ELSE 0 END END
				) > 0
				AND (C.Card_Point between @intPointFrom and @intPointTo)
				AND (C.Card_PointAccumulate between @intPointFrom_Acc and @intPointTo_Acc)
				AND (C.Card_Point_Tier between @intPointFrom_Tier and @intPointTo_Tier)
				AND (C.Card_Point_Hidden between @intPointFrom_Hidden and @intPointTo_Hidden)

			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY CO.CardOwner_ID)  AS RowNo,
				DATEDIFF(YEAR, CO.CardOwner_DOB, GETDATE()) as Age, *,
				ISNULL(PL.PlayerLevel_Name,'') as PlayerLevel_Name2,
				(CASE Card_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Card_StatusText,
				CardType_Name as Card_TypeText
				from tblCardOwner CO (NOLOCK)
				inner join tblPlayerLevel PL (NOLOCK) on PL.PlayerLevel_ID = CO.CardOwner_Level
				inner join tblCard C (NOLOCK) on C.Card_CardOwner_ID = CO.CardOwner_ID
				inner join tblCardType CT (NOLOCK) on C.Card_Type = CT.CardType_ID
				where (DATEDIFF(YEAR, CO.CardOwner_DOB, GETDATE()) between @intAgeFrom and  @intAgeTo)
				AND (
				CASE WHEN @intGender = -1 THEN 1 ELSE
				CASE WHEN CO.CardOwner_Gender = @intGender THEN 1 ELSE 0 END END
				) > 0
				AND (C.Card_Point between @intPointFrom and @intPointTo)
				AND (C.Card_PointAccumulate between @intPointFrom_Acc and @intPointTo_Acc)
				AND (C.Card_Point_Tier between @intPointFrom_Tier and @intPointTo_Tier)
				AND (C.Card_Point_Hidden between @intPointFrom_Hidden and @intPointTo_Hidden)
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			--Order by Card_Status, Card_SerialNo
	END
END
