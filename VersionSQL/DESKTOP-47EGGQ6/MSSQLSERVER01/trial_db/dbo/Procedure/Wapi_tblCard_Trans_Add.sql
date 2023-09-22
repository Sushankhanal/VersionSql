/****** Object:  Procedure [dbo].[Wapi_tblCard_Trans_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
--exec Wapi_tblCard_Trans_Add '23432532',22,100,'','','',''
CREATE PROCEDURE [dbo].[Wapi_tblCard_Trans_Add]
-- Add the parameters for the stored procedure her
@strCardNumber      NVARCHAR(50), 
@intTransType       INT, 
@dblValue           MONEY, 
@strRemarks         NVARCHAR(50), 
@strUserID          NVARCHAR(50), 
@strManagerLogin    NVARCHAR(50) = '', 
@strManagerPassword NVARCHAR(50) = ''
AS
BEGIN
	   DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value=[dbo].[Local_Wapi_tblCard_Trans_Add]
	@strCardNumber,
@intTransType,
@dblValue,
@strRemarks,
@strUserID,
@strManagerLogin,
@strManagerPassword,
@cardid output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_Wapi_tblCard_Trans_Add]
			@strCardNumber,
@intTransType,
@dblValue,
@strRemarks,
@strUserID,
@strManagerLogin,
@strManagerPassword

    end
END
