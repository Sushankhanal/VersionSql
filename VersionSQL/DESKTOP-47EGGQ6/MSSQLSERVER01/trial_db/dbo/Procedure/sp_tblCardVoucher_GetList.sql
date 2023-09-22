/****** Object:  Procedure [dbo].[sp_tblCardVoucher_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblCardVoucher_GetList] (
	@strCardVoucher_Num			nvarchar(200),
	@strCardOwner_Name			nvarchar(200),
	@intStatus					smallint,
	@dateFrom					datetime,
	@dateTo						datetime,
	@StartRecord INT,
	@EndRecord INT,
	@IsCount INT
) AS
BEGIN

	set @dateTo = DATEADD(day,1,@dateTo)
	set @dateTo = DATEADD(second,-1,@dateTo)

	Declare @strStatus nvarchar(50)
	set @strStatus = @intStatus
	if @intStatus = -1
	BEGIN
		set @strStatus = ''
	END

		--select CardVoucher_ID, CardVoucher_GenerateDate, CardVoucher_Number, CardVoucher_Value, CardVoucher_Status, CardVoucher_Expired, 
		--C.Card_SerialNo, CO.CardOwner_Name from tblCard_Voucher V (NOLOCK) 
		--inner join tblCard C (NOLOCK) on V.CardVoucher_Card_ID = C.Card_ID
		--inner join tblCardOwner CO (NOLOCK) on CO.CardOwner_ID = V.CardVoucher_CardOwner_ID
		--WHERE V.CardVoucher_Number LIKE '%' + @strCardVoucher_Num + '%'
		--AND CO.CardOwner_Name LIKE '%' + @strCardOwner_Name + '%'
		--AND V.CardVoucher_GenerateDate BETWEEN @dateFrom AND @dateTo
		--AND V.CardVoucher_Status LIKE '%' + @strStatus + '%'

	IF @IsCount = 1 
	BEGIN
		SELECT COUNT(RowNo) AS intRowCount FROM
			(
				select ROW_NUMBER() OVER(ORDER BY V.CardVoucher_Number)  AS RowNo
				from tblCard_Voucher V (NOLOCK) 
				inner join tblCard C (NOLOCK) on V.CardVoucher_Card_ID = C.Card_ID
				inner join tblCardOwner CO (NOLOCK) on CO.CardOwner_ID = V.CardVoucher_CardOwner_ID
				WHERE V.CardVoucher_Number LIKE '%' + @strCardVoucher_Num + '%'
				AND CO.CardOwner_Name LIKE '%' + @strCardOwner_Name + '%'
				AND V.CardVoucher_GenerateDate BETWEEN @dateFrom AND @dateTo
				AND V.CardVoucher_Status LIKE '%' + @strStatus + '%'
			)tblA
	END
	ELSE
	BEGIN
		SELECT * FROM 
			(			
				select ROW_NUMBER() OVER(ORDER BY V.CardVoucher_Number)  AS RowNo,
				CardVoucher_ID, CardVoucher_GenerateDate, CardVoucher_Number, CardVoucher_Value, 
				(CASE CardVoucher_Status WHEN 0 THEN 'New' WHEN 1 THEN 'Used' ELSE 'Expired' END) AS CardVoucher_Status, 
				CardVoucher_Expired, C.Card_SerialNo, CO.CardOwner_Name 
				from tblCard_Voucher V (NOLOCK) 
				inner join tblCard C (NOLOCK) on V.CardVoucher_Card_ID = C.Card_ID
				inner join tblCardOwner CO (NOLOCK) on CO.CardOwner_ID = V.CardVoucher_CardOwner_ID
				WHERE V.CardVoucher_Number LIKE '%' + @strCardVoucher_Num + '%'
				AND CO.CardOwner_Name LIKE '%' + @strCardOwner_Name + '%'
				AND V.CardVoucher_GenerateDate BETWEEN @dateFrom AND @dateTo
				AND V.CardVoucher_Status LIKE '%' + @strStatus + '%'
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by CardVoucher_Number
	END
	--Status: 0: New, 1: Used, 2: Expired
	--Filter by Generate date from and to, card number, card owner name
END
