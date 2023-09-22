/****** Object:  Procedure [dbo].[api_CardMoneyOutByAmt]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[api_CardMoneyOutByAmt]
-- Add the parameters for the stored procedure here
@strUniqueID    NVARCHAR(50), 
@strCardNo      NVARCHAR(50), 
@intType        INT, 
@strCompanyCode NVARCHAR(50), 
@dblTotal       MONEY OUT, 
@dblMoneyOutAmt MONEY        = 0

AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_api_CardMoneyOutByAmt]
		@strUniqueID,
@strCardNo,
@intType,
@strCompanyCode,
@dblTotal OUT,
@dblMoneyOutAmt ,
		@cardid output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;


    
   END TRY
   BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
    PRINT @ErrorMessage
END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_api_CardMoneyOutByAmt]
		@strUniqueID,
@strCardNo,
@intType,
@strCompanyCode,
@dblTotal OUT,
@dblMoneyOutAmt = 0

    end

END
