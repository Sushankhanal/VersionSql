/****** Object:  Procedure [dbo].[sp_GiveBonusCreditPoint_Campaign]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GiveBonusCreditPoint_Campaign] @intUserID         BIGINT, 
                                                         @strCardNumber     NVARCHAR(50), 
                                                         @dblAddPoint       DECIMAL(38, 10), 
                                                         @strRemarks        NVARCHAR(500), 
                                                         @strPOSUserCode    NVARCHAR(50), 
                                                         @strCompanyCode    NVARCHAR(50), 
                                                         @strClientFullName NVARCHAR(50) OUT, 
                                                         @strClientBalance  MONEY OUT, 
                                                         @strClientPoint    DECIMAL(38, 10) OUT, 
                                                         @intLocalTransID   INT, 
                                                         @intBranchID       INT, 
                                                         @intMachineID      INT, 
                                                         @intCampaignID     BIGINT, 
                                                         @strTransTimespan  NVARCHAR(50), 
                                                         @intPointTransType INT             = 0
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_sp_GiveBonusCreditPoint_Campaign]
		 @intUserID ,
                                                @strCardNumber , 
                                                @dblAddPoint , 
                                                @dblAddPoint, 
                                                @strRemarks,
                                                @strPOSUserCode,
                                                @strCompanyCode,
                                                @strClientFullName,
                                                @strClientBalance , 
                                                @strClientPoint,
                                                @intLocalTransID,
                                                @intBranchID ,
                                                @intMachineID ,
                                              @intCampaignID   , 
                                                         @strTransTimespan, 
                                                         @intPointTransType , 
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
	 EXEC[dbo].[Local_sp_GiveBonusCreditPoint_Campaign]
		 @intUserID ,
                                                @strCardNumber , 
                                                @dblAddPoint , 
                                                @dblAddPoint, 
                                                @strRemarks,
                                                @strPOSUserCode,
                                                @strCompanyCode,
                                                @strClientFullName,
                                                @strClientBalance , 
                                                @strClientPoint,
                                                @intLocalTransID,
                                                @intBranchID ,
                                                @intMachineID ,
                                              @intCampaignID   , 
                                                         @strTransTimespan, 
                                                         @intPointTransType

  
  end
END
