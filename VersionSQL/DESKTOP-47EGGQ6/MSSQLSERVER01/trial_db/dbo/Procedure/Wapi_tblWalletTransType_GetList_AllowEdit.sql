/****** Object:  Procedure [dbo].[Wapi_tblWalletTransType_GetList_AllowEdit]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblPlayerLevel_GetByStatus '',-1,'',0,100,0
CREATE PROCEDURE [dbo].[Wapi_tblWalletTransType_GetList_AllowEdit] 

 AS
BEGIN
	select * from tblWalletTransType a (NOLOCK) where a.WTransType_AllowEdit = 1
END
