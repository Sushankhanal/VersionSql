/****** Object:  Procedure [dbo].[Wapi_tblPOSUser_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
Create PROCEDURE [dbo].[Wapi_tblPOSUser_GetList] (
	@intCashierID	bigint = -1
) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY POSUser_Code)  AS RowNo,
				*, 
				(CASE POSUser_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as POSUser_StatusText
				from tblPOSUser (NOLOCK)
				where POSUser_UserType = 0 AND
				(CASE WHEN @intCashierID = -1 THEN 1 ELSE CASE WHEN POSUser_ID = @intCashierID THEN 1 ELSE 0 END END) > 0

END
