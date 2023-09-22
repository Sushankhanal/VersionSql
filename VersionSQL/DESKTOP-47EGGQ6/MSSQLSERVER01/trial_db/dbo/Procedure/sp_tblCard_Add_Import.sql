/****** Object:  Procedure [dbo].[sp_tblCard_Add_Import]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCard_Add_Import]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strSerialNo	nvarchar(50),
	@intType	smallint,
	@intStatus	smallint,
	@strOwnerName	nvarchar(50),
	@strOwnerMobile	nvarchar(50),
	@intOwnerGender	smallint,
	@strUsercode	nvarchar(50),
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
	@strCardNumber		nvarchar(50) = '',
	@strPic				nvarchar(max) =''
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
    

EXEC [dbo].[Cloud_sp_tblCard_Add_Import]
	@ID	,
	@strSerialNo,
	@intType,
	@intStatus,
	@strOwnerName,
	@strOwnerMobile,
	@intOwnerGender,
	@strUsercode,
	@strMembership,
	@strIC,
	@strAddress	,
	@strFamilyName,
	@intCountry	,
	@intGender	, 
	@intLevel, 
	@dtDOB	,
	@strEmail,
	@intIDType,
	@strRemarks	,
	@intBarred, 
	@strBarredReason,
	@stralterdBy,
	@strCardNumber,
	@strPic	

    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_sp_tblCard_Add_Import]
		@ID	,
	@strSerialNo,
	@intType,
	@intStatus,
	@strOwnerName,
	@strOwnerMobile,
	@intOwnerGender,
	@strUsercode,
	@strMembership,
	@strIC,
	@strAddress	,
	@strFamilyName,
	@intCountry	,
	@intGender	, 
	@intLevel, 
	@dtDOB	,
	@strEmail,
	@intIDType,
	@strRemarks	,
	@intBarred, 
	@strBarredReason,
	@stralterdBy,
	@strCardNumber,
	@strPic	

    end

END
