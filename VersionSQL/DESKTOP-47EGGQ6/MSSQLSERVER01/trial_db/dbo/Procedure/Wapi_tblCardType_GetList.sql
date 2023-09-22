/****** Object:  Procedure [dbo].[Wapi_tblCardType_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[Wapi_tblCardType_GetList] (
	@strName			nvarchar(50),
	@intStatus			smallint,
	--@strUserCode		nvarchar(50),
	@intCardTypeID	bigint = -1

) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY CardType_Name)  AS RowNo,
	C.*, 
	(CASE CardType_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as CardType_StatusText
	from tblCardType C (NOLOCK)
	where CardType_Name LIKE '%' + @strName + '%' AND
	(CASE WHEN @intStatus = -1 THEN 1 ELSE CASE WHEN C.CardType_Status = @intStatus THEN 1 ELSE 0 END END) > 0
	AND (CASE WHEN @intCardTypeID = -1 THEN 1 ELSE CASE WHEN C.CardType_ID = @intCardTypeID THEN 1 ELSE 0 END END) > 0
END
