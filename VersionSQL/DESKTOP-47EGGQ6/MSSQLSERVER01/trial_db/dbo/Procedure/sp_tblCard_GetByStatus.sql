/****** Object:  Procedure [dbo].[sp_tblCard_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblCard_GetByStatus] (
	@strSerialNumber	nvarchar(50),
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
				select ROW_NUMBER() OVER(ORDER BY Card_SerialNo)  AS RowNo
				from tblCard C (NOLOCK)
				left outer join tblCardOwner O on C.Card_SerialNo = O.CardOwner_CardSerialNo
				where Card_SerialNo LIKE '%' + @strSerialNumber + '%' AND
					ISNULL(O.CardOwner_Name,'') LIKE '%' + @strName + '%'
					AND C.Card_Status LIKE '%' + @strStatus + '%' AND
					C.Card_CompanyCode = @strCompanyCode
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				select ROW_NUMBER() OVER(ORDER BY Card_SerialNo)  AS RowNo,
				C.*, 
				(CASE Card_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Card_StatusText,
				--(CASE Card_Type WHEN 0 THEN 'Normal' ELSE 'VIP' END) as Card_TypeText,
				CT.CardType_Name as Card_TypeText,
				ISNULL(O.CardOwner_Name,'') as CardOwner_Name,
				ISNULL(O.CardOwner_MobileNumber,'') as CardOwner_MobileNumber,
				ISNULL(O.CardOwner_Gender,0) as CardOwner_Gender
				from tblCard C (NOLOCK)
				left outer join tblCardOwner O on C.Card_SerialNo = O.CardOwner_CardSerialNo
				inner join tblCardType CT (NOLOCK) on CT.CardType_ID = C.Card_Type
				where Card_SerialNo LIKE '%' + @strSerialNumber + '%' AND
					ISNULL(O.CardOwner_Name,'') LIKE '%' + @strName + '%'
					AND C.Card_Status LIKE '%' + @strStatus + '%' AND
					C.Card_CompanyCode = @strCompanyCode
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by Card_Status, Card_SerialNo
	END
END
