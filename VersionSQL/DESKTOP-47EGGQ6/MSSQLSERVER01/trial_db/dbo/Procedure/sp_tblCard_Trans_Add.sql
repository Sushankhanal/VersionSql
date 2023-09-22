/****** Object:  Procedure [dbo].[sp_tblCard_Trans_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCard_Trans_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strCardNumber	nvarchar(50),
	@intTransType	int,
	@dblValue		money,
	@strRemarks		nvarchar(50),
	@strUserID		nvarchar(50),
	@strBranchCode	nvarchar(50),
	@strManagerLogin	nvarchar(50) = '',
	@strManagerPassword	nvarchar(50) = ''
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
    

DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_sp_tblCard_Trans_Add]
		@ID	,
	@strCardNumber,
	@intTransType,
	@dblValue,
	@strRemarks,
	@strUserID,
	@strBranchCode,
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
	 EXEC[dbo].[Local_sp_tblCard_Trans_Add]
	@ID	,
	@strCardNumber,
	@intTransType,
	@dblValue,
	@strRemarks,
	@strUserID,
	@strBranchCode,
	@strManagerLogin,
	@strManagerPassword
    end

END
