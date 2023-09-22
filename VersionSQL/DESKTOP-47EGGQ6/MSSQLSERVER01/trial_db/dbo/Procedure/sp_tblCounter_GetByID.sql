/****** Object:  Procedure [dbo].[sp_tblCounter_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblCounter_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN

	select * from tblCounter where Counter_ID = @intID
END
