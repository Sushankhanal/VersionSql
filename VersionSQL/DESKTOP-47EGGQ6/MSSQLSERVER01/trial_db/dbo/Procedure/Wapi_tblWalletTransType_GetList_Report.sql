/****** Object:  Procedure [dbo].[Wapi_tblWalletTransType_GetList_Report]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblPlayerLevel_GetByStatus '',-1,'',0,100,0
Create PROCEDURE [dbo].[Wapi_tblWalletTransType_GetList_Report] 

 AS
BEGIN
	select * from tblWalletTransType a (NOLOCK) where a.WTransType_AllowDisplayAtReport = 1
END
