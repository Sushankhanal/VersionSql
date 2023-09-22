/****** Object:  Procedure [dbo].[Wapi_tblCard_GetAvailable]    Committed by VersionSQL https://www.versionsql.com ******/

--exec Wapi_tblCard_GetAvailable '',0
CREATE PROCEDURE [dbo].[Wapi_tblCard_GetAvailable] (
	@strSerialNumber	nvarchar(50),
	@intCardTypeID		BigInt
) AS
BEGIN
	
	
	select ROW_NUMBER() OVER(ORDER BY Card_SerialNo)  AS RowNo,
	C.*, 
	(CASE Card_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Card_StatusText,
	CT.CardType_Name
	from tblCard C (NOLOCK)
	inner join tblCardType CT on CT.CardType_ID = C.Card_Type
	where Card_SerialNo LIKE '%' + @strSerialNumber + '%' AND
	Card_CardOwner_ID IS NULL AND Card_Status = 0
	AND
	(
	CASE WHEN @intCardTypeID = -1 THEN 1 ELSE
	CASE WHEN Card_Type = @intCardTypeID THEN 1 ELSE 0 END END
	) > 0
END
