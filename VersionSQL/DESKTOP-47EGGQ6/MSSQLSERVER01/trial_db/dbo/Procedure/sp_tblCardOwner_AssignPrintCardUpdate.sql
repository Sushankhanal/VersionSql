/****** Object:  Procedure [dbo].[sp_tblCardOwner_AssignPrintCardUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCardOwner_AssignPrintCardUpdate]
	-- Add the parameters for the stored procedure here
	@intID				bigint output ,
	@intNewCardID		bigint, 
	@intPlayerID		bigint,
	@stralterdBy		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@strPic				nvarchar(50),
	@strOldCardNumber	nvarchar(50),
	@intTransType		int -- 0: New Assign, 1: Transfer

AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
    

	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value=  [dbo].[cloud_sp_tblCardOwner_AssignPrintCardUpdate]
		@intID	,
	@intNewCardID,
	@intPlayerID,
	@stralterdBy,
	@strCompanyCode	,
	@strPic	,
	@strOldCardNumber,
	@intTransType	,
	@cardid output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_sp_tblCardOwner_AssignPrintCardUpdate]
			@intID	,
	@intNewCardID,
	@intPlayerID,
	@stralterdBy,
	@strCompanyCode	,
	@strPic	,
	@strOldCardNumber,
	@intTransType
    end

END
