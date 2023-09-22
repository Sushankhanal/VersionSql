/****** Object:  Procedure [dbo].[Wapi_tblCardOwner_AssignPrintCardUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCardOwner_AssignPrintCardUpdate]
-- Add the parameters for the stored procedure here
@intNewCardID     BIGINT, 
@intPlayerID      BIGINT, 
@stralterdBy     NVARCHAR(50), 
@strCompanyCode   NVARCHAR(50), 
@strPic           NVARCHAR(50), 
@strOldCardNumber NVARCHAR(50), 
@intTransType     INT -- 0: New Assign, 1: Transfer

AS
   BEGIN
	   DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value=	[dbo].[Local_Wapi_tblCardOwner_AssignPrintCardUpdate]
@intNewCardID,
@intPlayerID,
@stralterdBy,
@strCompanyCode,
@strPic,
@strOldCardNumber,
@intTransType ,
@cardid output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_Wapi_tblCardOwner_AssignPrintCardUpdate]
	@intNewCardID,
@intPlayerID,
@stralterdBy,
@strCompanyCode,
@strPic,
@strOldCardNumber,
@intTransType 

    end
END
