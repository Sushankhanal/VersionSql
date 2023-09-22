/****** Object:  Procedure [dbo].[sp_tblPOSUser_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

Create PROCEDURE [dbo].[sp_tblPOSUser_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN

	select * from tblPOSUser where POSUser_ID = @intID
END
