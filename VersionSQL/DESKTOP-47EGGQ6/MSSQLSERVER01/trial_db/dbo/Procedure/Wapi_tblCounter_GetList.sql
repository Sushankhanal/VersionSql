/****** Object:  Procedure [dbo].[Wapi_tblCounter_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
Create PROCEDURE [dbo].[Wapi_tblCounter_GetList] (
	@intCounterID	bigint = -1
) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY Counter_Code)  AS RowNo,
				*, 
				(CASE Counter_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Counter_StatusText
				from tblCounter (NOLOCK)
				where (CASE WHEN @intCounterID = -1 THEN 1 ELSE CASE WHEN Counter_ID = @intCounterID THEN 1 ELSE 0 END END) > 0

END
