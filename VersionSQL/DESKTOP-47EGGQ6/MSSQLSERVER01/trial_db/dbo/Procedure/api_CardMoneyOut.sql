/****** Object:  Procedure [dbo].[api_CardMoneyOut]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[api_CardMoneyOut]
-- Add the parameters for the stored procedure here
@strUniqueID    NVARCHAR(50), 
@strCardNo      NVARCHAR(50), 
@intType        INT, 
@strCompanyCode NVARCHAR(50), 
@dblTotal       INT OUT
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_api_CardMoneyOut]
		@strUniqueID,
@strCardNo,
@intType,
@strCompanyCode,
@dblTotal OUT,
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
	 EXEC[dbo].[Local_api_CardMoneyOut]
	@strUniqueID,
@strCardNo,
@intType,
@strCompanyCode,
@dblTotal OUT
    end

END
