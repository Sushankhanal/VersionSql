/****** Object:  Procedure [dbo].[Wapi_tblCardOwner_AssignPrintCard]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCardOwner_AssignPrintCard]
	-- Add the parameters for the stored procedure here
	@strCardNumber		nvarchar(50), 
	@intCardType		int,
	@intPlayerID		bigint,
	@stralterdBy		nvarchar(50),
	@strCompanyCode		nvarchar(50)
AS
BEGIN
	   DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value=	[dbo].[Local_Wapi_tblCardOwner_AssignPrintCard]
	@strCardNumber,
	@intCardType,
	@intPlayerID,
	@stralterdBy,
	@strCompanyCode	,
	@cardid output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_Wapi_tblCardOwner_AssignPrintCard]
	@strCardNumber,
	@intCardType,
	@intPlayerID,
	@stralterdBy,
	@strCompanyCode	

    end
END
