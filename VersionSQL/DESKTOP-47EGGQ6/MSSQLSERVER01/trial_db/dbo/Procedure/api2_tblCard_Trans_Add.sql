/****** Object:  Procedure [dbo].[api2_tblCard_Trans_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[api2_tblCard_Trans_Add]
-- Add the parameters for the stored procedure here
@strCardNumber NVARCHAR(50), 
@dblAmt        MONEY, 
@intTransType  INT, 
@strUniqueKey  NVARCHAR(50)
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_api2_tblCard_Trans_Add]
		@strCardNumber,
		@dblAmt,
		@intTransType,
		@strUniqueKey,
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
	 EXEC[dbo].[Local_api2_tblCard_Trans_Add]
		@strCardNumber,
		@dblAmt,
		@intTransType,
		@strUniqueKey
    end

END
