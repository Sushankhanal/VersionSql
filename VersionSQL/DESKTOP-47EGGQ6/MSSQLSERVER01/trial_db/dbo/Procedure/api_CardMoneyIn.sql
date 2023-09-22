/****** Object:  Procedure [dbo].[api_CardMoneyIn]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[api_CardMoneyIn]
    @strUniqueID NVARCHAR(50), 
    @strCardNo NVARCHAR(50), 
    @dblAmount MONEY, 
    @intType INT, 
    @strCompanyCode NVARCHAR(50)
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer' -- Replace with your linked server name

    IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
    BEGIN
        BEGIN TRY
            -- Try executing the second stored procedure on the linked server
            EXEC [dbo].[Cloud_api_CardMoneyIn] @strUniqueID, @strCardNo, @dblAmount, @intType, @strCompanyCode
            PRINT 200 -- Success
        END TRY
        BEGIN CATCH
		
            IF ERROR_NUMBER() IN (53, 64, 121, 18456) -- Specific network-related error codes
			
            BEGIN
			
                PRINT 'Network issue. Cannot connect to the remote server.'
			
            END
            ELSE
            BEGIN
			
                DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE()
                RAISERROR(@ErrorMessage, 16, 1) -- Raise custom error message
            END
        END CATCH
    END
    ELSE
    BEGIN
        PRINT 300
        EXEC [dbo].[Local_api_CardMoneyIn] @strUniqueID, @strCardNo, @dblAmount, @intType, @strCompanyCode
    END
END
