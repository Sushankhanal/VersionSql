/****** Object:  Procedure [dbo].[Wapi_tblCard_Add_Import]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCard_Add_Import]
	-- Add the parameters for the stored procedure here
	@strSerialNo	nvarchar(50),
	@intType	smallint,
	@intStatus	smallint,
	@strOwnerName	nvarchar(50),
	@strOwnerMobile	nvarchar(50),
	@strMembership	nvarchar(100),
	@strIC		nvarchar(50),
	@strAddress		nvarchar(max),
	@strFamilyName		nvarchar(50), 
	@intCountry		int, 
	@intGender			int, 
	@intLevel			int, 
	@dtDOB				nvarchar(50), 
	@strEmail			nvarchar(50), 
	@intIDType			int, 
	@strRemarks			nvarchar(500), 
	@intBarred			int, 
	@strBarredReason	nvarchar(255),
	@stralterdBy		int,
	@strPic				nvarchar(max) =''
AS
BEGIN
	   DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
	declare
	@return_value int,  
	@CardOwnerId        bigint,
	@CardId             bigint
EXEC	[dbo].[Local_Wapi_tblCard_Add_Import]
		@strSerialNo,
	@intType,
	@intStatus,
	@strOwnerName,
	@strOwnerMobile,
	@strMembership,
	@strIC,
	@strAddress	,
	@strFamilyName, 
	@intCountry, 
	@intGender, 
	@intLevel, 
	@dtDOB, 
	@strEmail, 
	@intIDType, 
	@strRemarks, 
	@intBarred, 
	@strBarredReason,
	@stralterdBy,
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
	 EXEC[dbo].[Local_Wapi_tblCard_Add_Import]
	@strSerialNo,
	@intType,
	@intStatus,
	@strOwnerName,
	@strOwnerMobile,
	@strMembership,
	@strIC,
	@strAddress	,
	@strFamilyName, 
	@intCountry, 
	@intGender, 
	@intLevel, 
	@dtDOB, 
	@strEmail, 
	@intIDType, 
	@strRemarks, 
	@intBarred, 
	@strBarredReason,
	@stralterdBy,
	@strPic	

    end
END
