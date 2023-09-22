/****** Object:  Procedure [dbo].[sp_tblCardOwner_Add_Kiosk]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCardOwner_Add_Kiosk]
	-- Add the parameters for the stored procedure here
	@intID				bigint OUT,
	@strFirstName		nvarchar(50), 
	@strMobileNumber	nvarchar(50), 
	@intGender			int, 
	@strMembership		nvarchar(50), 
	@strIC				nvarchar(50), 
	@strAddress			nvarchar(500),
	@strFamilyName		nvarchar(50), 
	@intCountry		int, 
	@intStatus			int, 
	@intLevel			int, 
	@dtDOB				nvarchar(50), 
	@strEmail			nvarchar(50), 
	@intIDType			int, 
	@strRemarks			nvarchar(500), 
	@intBarred			int, 
	@strBarredReason	nvarchar(255),
	@stralterdBy		int,
	@strCardNumber		nvarchar(50) = '',
	@strCardPin			nvarchar(50)  = '' OUT,
	@strPic				nvarchar(max) ='',
	@strCompanyCode		nvarchar(50)  = '',
	@intCardType		int = 0,
	@strCardNumberNew	nvarchar(50) = '' OUT
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
    
declare
	@return_value int,  
	@CardOwnerId        bigint,
	@CardId             bigint
EXEC	@return_value=[dbo].[Local_sp_tblCardOwner_Add_Kiosk]
		@intID,
	@strFirstName,
	@strMobileNumber,
	@intGender,
	@strMembership,
	@strIC,
	@strAddress	,
	@strFamilyName,
	@intCountry,
	@intStatus,
	@intLevel,
	@dtDOB,
	@strEmail,
	@intIDType,
	@strRemarks,
	@intBarred,
	@strBarredReason,
	@stralterdBy,
	@strCardNumber,
	@strCardPin	,
	@strPic	,
		@strCompanyCode	,
	@intCardType,
	@strCardNumberNew,
	@CardOwnerId output,
    @CardId output;

	EXEC[dbo].[Sync_CardOwnerInsertUpdate] @CardOwnerId = @CardOwnerId;
EXEC [dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_sp_tblCardOwner_Add_Kiosk]
		@intID,
	@strFirstName,
	@strMobileNumber,
	@intGender,
	@strMembership,
	@strIC,
	@strAddress	,
	@strFamilyName,
	@intCountry,
	@intStatus,
	@intLevel,
	@dtDOB,
	@strEmail,
	@intIDType,
	@strRemarks,
	@intBarred,
	@strBarredReason,
	@stralterdBy,
	@strCardNumber,
	@strCardPin	,
	@strPic	,
		@strCompanyCode	,
	@intCardType,
	@strCardNumberNew
    
    end

END
