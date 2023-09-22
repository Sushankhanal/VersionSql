/****** Object:  Procedure [dbo].[mobile_get_user_info_gaming_day_3rd]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_get_user_info_gaming_day_3rd] @card_sn        NVARCHAR(50), 
                                                            @machine_id     BIGINT, 
                                                            @start          DATETIME, 
                                                            @end            DATETIME, 
                                                            @cardOwner_name NVARCHAR(50), 
                                                            @companyCode    NVARCHAR(50)
AS
 
 BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer' -- Replace with your linked server name
	
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
	
            declare
	@return_value int,  
	@CardOwnerId        bigint,
	@CardId             bigint
EXEC	@return_value= [dbo].[Local_mobile_get_user_info_gaming_day_3rd] @card_sn, @machine_id,@start, @end,@cardOwner_name,@companyCode,
				@CardOwnerId output,
    @CardId output;

	EXEC[dbo].[Sync_CardOwnerInsertUpdate] @CardOwnerId = @CardOwnerId;
EXEC [dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
	 
	END TRY
    BEGIN CATCH
	
    END CATCH
	end
	else
	begin

	 EXEC [dbo].[Local_mobile_get_user_info_gaming_day_3rd] @card_sn, @machine_id,@start, @end,@cardOwner_name,@companyCode 
	end
	
END
