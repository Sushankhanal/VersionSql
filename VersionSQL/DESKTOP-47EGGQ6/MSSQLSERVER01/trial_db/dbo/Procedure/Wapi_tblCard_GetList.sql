/****** Object:  Procedure [dbo].[Wapi_tblCard_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec Wapi_tblCard_GetList '','s',-1,-1
CREATE PROCEDURE [dbo].[Wapi_tblCard_GetList] (
	@strSerialNumber	nvarchar(50) ='',
	@strName			nvarchar(50),
	@intStatus			smallint,
	@intCardID	bigint = -1

) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY Card_SerialNo)  AS RowNo,
				C.*, 
				(CASE Card_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Card_StatusText,
				ISNULL(O.CardOwner_Name,'') as CardOwner_Name,
				ISNULL(O.CardOwner_MobileNumber,'') as CardOwner_MobileNumber,
				ISNULL(O.CardOwner_Gender,0) as CardOwner_Gender,
				CT.CardType_Name
				from tblCard C (NOLOCK)
				left outer join tblCardOwner O on C.Card_CardOwner_ID = O.CardOwner_ID
				inner join tblCardType CT (NOLOCK) on CT.CardType_ID = C.Card_Type
				where Card_SerialNo LIKE '%' + @strSerialNumber + '%' AND
				ISNULL(O.CardOwner_Name,'') LIKE '%' + @strName + '%' AND
				(CASE WHEN @intStatus = -1 THEN 1 ELSE CASE WHEN C.Card_Status = @intStatus THEN 1 ELSE 0 END END) > 0
				AND (CASE WHEN @intCardID = -1 THEN 1 ELSE CASE WHEN C.Card_ID = @intCardID THEN 1 ELSE 0 END END) > 0
				Order by Card_SerialNo
END
