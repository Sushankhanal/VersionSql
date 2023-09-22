/****** Object:  Procedure [dbo].[clsc_loginv2]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[clsc_loginv2] @card_sn           NVARCHAR(50), 
                                     @start             DATETIME, 
                                     @end               DATETIME, 
                                     @app_version       NVARCHAR(50), 
                                     @setting_version   NVARCHAR(50), 
                                     @ip                NVARCHAR(50), 
                                     @imei              NVARCHAR(50), 
                                     @cardOwner_name    NVARCHAR(50), 
                                     @companyCode       NVARCHAR(50), 
                                     @player_level_text NVARCHAR(MAX)
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
EXEC	@return_value= [dbo].[Local_clsc_loginv2] @card_sn, @start, @end, @app_version, @setting_version,@ip,@imei,@cardOwner_name,@companyCode,@player_level_text,
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

	 EXEC [dbo].[Local_clsc_loginv2] @card_sn, @start, @end, @app_version, @setting_version,@ip,@imei,@cardOwner_name,@companyCode,@player_level_text
	end
	
END
