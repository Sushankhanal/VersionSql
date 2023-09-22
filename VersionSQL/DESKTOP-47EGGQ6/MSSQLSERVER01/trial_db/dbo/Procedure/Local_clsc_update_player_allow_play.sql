/****** Object:  Procedure [dbo].[Local_clsc_update_player_allow_play]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec api_SaveOrderMaster 'comp02','Tablet01','Tablet01','R8',''
CREATE PROCEDURE [dbo].[Local_clsc_update_player_allow_play] @cardSrn NVARCHAR(50),
  @CardOwnerId        bigint = NULL OUTPUT,
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        UPDATE A
          SET 
              A.CardOwner_clsc_allow_play = 0, 
              A.CardOwner_clsc_allow_play_message = NULL
        FROM tblCardOwner A
             JOIN tblCard ON tblCard.Card_CardOwner_ID = A.CardOwner_ID
        WHERE tblCard.Card_SerialNo = @cardSrn;
		set @CardId=@cardSrn;
		set @CardOwnerId=@cardSrn;
    END;
