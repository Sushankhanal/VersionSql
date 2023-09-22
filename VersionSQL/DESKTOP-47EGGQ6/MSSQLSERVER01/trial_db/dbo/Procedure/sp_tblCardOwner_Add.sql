/****** Object:  Procedure [dbo].[sp_tblCardOwner_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCardOwner_Add]
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
	@strPic				nvarchar(max) =''

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
EXEC	@return_value= [dbo].[Local_sp_tblCardOwner_Add]
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
	 EXEC[dbo].[Local_sp_tblCardOwner_Add]
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
	@strPic	
    end

END
