/****** Object:  Procedure [dbo].[Wapi_tblIDType_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Wapi_tblIDType_GetList] (
	@intIDTypeID	bigint = -1
) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY IDType_Sort)  AS RowNo, *
	from tblIDType P (NOLOCK)
	where (CASE WHEN @intIDTypeID = -1 THEN 1 ELSE CASE WHEN IDType_ID = @intIDTypeID THEN 1 ELSE 0 END END) > 0
	AND IDType_Status = 0
	Order by IDType_Sort

END
