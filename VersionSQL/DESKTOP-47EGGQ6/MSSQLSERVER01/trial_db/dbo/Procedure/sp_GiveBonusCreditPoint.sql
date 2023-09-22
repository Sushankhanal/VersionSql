/****** Object:  Procedure [dbo].[sp_GiveBonusCreditPoint]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GiveBonusCreditPoint] @intUserID             BIGINT, 
                                                @strCardNumber         NVARCHAR(50), 
                                                @dblAddAmt             MONEY, 
                                                @dblAddPoint           DECIMAL(38, 10), 
                                                @strRemarks            NVARCHAR(500), 
                                                @strPOSUserCode        NVARCHAR(50), 
                                                @strCompanyCode        NVARCHAR(50), 
                                                @strClientFullName     NVARCHAR(50) OUT, 
                                                @strClientBalance      MONEY OUT, 
                                                @strClientPoint        DECIMAL(38, 10) OUT, 
                                                @intLocalTransID       NVARCHAR(100), 
                                                @intBranchID           INT, 
                                                @intMachineID          INT, 
                                                @dblAddAmt_NonCashable MONEY, 
                                                @dblAddAmt_Cashable    MONEY, 
                                                @strExtraInfo          XML, 
                                                @strTransTimespan      NVARCHAR(50), 
                                                @intPointTransType     INT             = 0, 
                                                @strTransNo            NVARCHAR(50) OUT
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_sp_GiveBonusCreditPoint]
		 @intUserID ,
                                                @strCardNumber , 
                                                @dblAddAmt , 
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
                                                @dblAddAmt_NonCashable, 
                                                @dblAddAmt_Cashable,
                                                @strExtraInfo,
                                                @strTransTimespan,
                                                @intPointTransType,
                                                @strTransNo,
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
	 EXEC[dbo].[Local_sp_GiveBonusCreditPoint]
		 @intUserID ,
                                                @strCardNumber , 
                                                @dblAddAmt , 
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
                                                @dblAddAmt_NonCashable, 
                                                @dblAddAmt_Cashable,
                                                @strExtraInfo,
                                                @strTransTimespan,
                                                @intPointTransType,
                                                @strTransNo

  
  end
END
