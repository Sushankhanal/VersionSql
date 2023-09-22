/****** Object:  Procedure [dbo].[Local_clsc_update_player_allow_play_status]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec api_SaveOrderMaster 'comp02','Tablet01','Tablet01','R8',''
CREATE PROCEDURE [dbo].[Local_clsc_update_player_allow_play_status] @cardSrn NVARCHAR(50), 
                                                             @status  INT, 
                                                             @msg     NVARCHAR(1024),
															   @CardOwnerId        bigint = NULL OUTPUT,
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        UPDATE A
          SET 
              A.CardOwner_clsc_allow_play = @status, 
              A.CardOwner_clsc_allow_play_message = @msg
        FROM tblCardOwner A
             JOIN tblCard ON tblCard.Card_CardOwner_ID = A.CardOwner_ID
        WHERE tblCard.Card_SerialNo = @cardSrn;
		set @CardId=@cardSrn;
		set @CardOwnerId=@cardSrn;
    END;
