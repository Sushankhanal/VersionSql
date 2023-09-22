/****** Object:  Procedure [dbo].[sp_tblPlayerLevel_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblPlayerLevel_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN

	select * from tblPlayerLevel where PlayerLevel_ID = @intID
END
