/****** Object:  Procedure [dbo].[clsc_get_card]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[clsc_get_card] @card_no NVARCHAR(MAX)
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT tblCard.Card_SerialNo, 
               tblCardOwner.CardOwner_Name
        FROM tblCard
             INNER JOIN tblCardOwner ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID
        WHERE(CASE
                  WHEN @card_no = '0'
                  THEN 1
                  ELSE CASE
                           WHEN Card_SerialNo LIKE('%' + @card_no + '%')
                           THEN 1
                           ELSE 0
                       END
              END) > 0;
    END;
