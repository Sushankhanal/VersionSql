/****** Object:  Procedure [dbo].[Wapi_tblCard_Voucher_Add_Auto]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblCard_Voucher_Add_Auto 0 ,100,0,12,'Manager'
CREATE PROCEDURE [dbo].[Wapi_tblCard_Voucher_Add_Auto]
	-- Add the parameters for the stored procedure here
	@dblValue	money,
	@intType	int,
	@intCardID	bigint,
	@strUsercode		nvarchar(50)
AS
BEGIN
	   DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY

EXEC	[dbo].[Cloud_Wapi_tblCard_Voucher_Add_Auto]
	@dblValue,
	@intType,
	@intCardID,
	@strUsercode
    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_Wapi_tblCard_Voucher_Add_Auto]
		@dblValue,
	@intType,
	@intCardID,
	@strUsercode

    end
END
