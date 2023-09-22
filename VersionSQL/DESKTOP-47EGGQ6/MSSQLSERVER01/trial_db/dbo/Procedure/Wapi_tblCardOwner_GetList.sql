/****** Object:  Procedure [dbo].[Wapi_tblCardOwner_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[Wapi_tblCardOwner_GetList]
(@strName       NVARCHAR(50), 
 @strIDNumber   NVARCHAR(50), 
 @intStatus     SMALLINT, 
 @strUserCode   NVARCHAR(50), 
 @intGender     SMALLINT     = -1, 
 @intCountry    INT          = -1, 
 @intLevel      INT          = -1, 
 @strCardNumber NVARCHAR(50) = '', 
 @intAgeFrom    INT          = 0, 
 @intAgeTo      INT          = 99, 
 @intPlayerID   INT          = -1
)
AS
    BEGIN
        DECLARE @strCompanyCode NVARCHAR(50);
        --select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode
        SELECT TOP 1 @strCompanyCode = Company_Code
        FROM tblCompany c(NOLOCK)
        ORDER BY Company_ID;

        --Declare @strStatus nvarchar(50)
        --set @strStatus = @intStatus
        --if @intStatus = -1
        --BEGIN
        --	set @strStatus = ''
        --END

        IF @intPlayerID <> -1
            BEGIN
                SET @intAgeTo = 999999;
            END;
        IF @strCardNumber = ''
            BEGIN
                SELECT ROW_NUMBER() OVER(
                       ORDER BY CO.CardOwner_ID) AS RowNo, 
                       CO.*, 
                       ISNULL(C.Country_Name, '') AS Country_Name, 
                       (CASE CardOwner_Gender
                            WHEN 0
                            THEN 'Male'
                            ELSE 'Female'
                        END) AS CardOwner_GenderText, 
                       ISNULL(PL.PlayerLevel_Name, '') AS PlayerLevel_Name, 
                       DATEDIFF(Y, YEAR(ISNULL(CardOwner_DOB, GETDATE())), YEAR(GETDATE())) AS PlayerAge, 
                       (CASE CardOwner_Status
                            WHEN 0
                            THEN 'Active'
                            ELSE 'Inactive'
                        END) AS CardOwner_StatusText, 
                       ISNULL(
                (
                    SELECT SUM(Card_PointAccumulate)
                    FROM tblCard
                    WHERE Card_CardOwner_ID = CO.CardOwner_ID
                ), 0) AS AccumulatePoint
                FROM tblCardOwner CO(NOLOCK)
                     LEFT OUTER JOIN tblCountry C ON C.Country_ID = CO.CardOwner_Country_ID
                     INNER JOIN tblPlayerLevel PL ON PL.PlayerLevel_ID = CO.CardOwner_Level
                WHERE CardOwner_Name LIKE '%' + @strName + '%'
                      AND CardOwner_IC LIKE '%' + @strIDNumber + '%'
                      AND (CASE
                               WHEN @intGender = -1
                               THEN 1
                               ELSE CASE
                                        WHEN CardOwner_Gender = @intGender
                                        THEN 1
                                        ELSE 0
                                    END
                           END) > 0
                      AND (CASE
                               WHEN @intCountry = -1
                               THEN 1
                               ELSE CASE
                                        WHEN CardOwner_Country_ID = @intCountry
                                        THEN 1
                                        ELSE 0
                                    END
                           END) > 0
                      AND (CASE
                               WHEN @intLevel = -1
                               THEN 1
                               ELSE CASE
                                        WHEN CardOwner_Level = @intLevel
                                        THEN 1
                                        ELSE 0
                                    END
                           END) > 0
                      AND (DATEDIFF(Y, YEAR(ISNULL(CardOwner_DOB, GETDATE())), YEAR(GETDATE())) BETWEEN @intAgeFrom AND @intAgeTo)
                      AND (CASE
                               WHEN @intPlayerID = -1
                               THEN 1
                               ELSE CASE
                                        WHEN CardOwner_ID = @intPlayerID
                                        THEN 1
                                        ELSE 0
                                    END
                           END) > 0
                ORDER BY LEN(CardOwner_Name), 
                         CardOwner_Name;
            END;
            ELSE
            BEGIN
                SELECT ROW_NUMBER() OVER(
                       ORDER BY CO.CardOwner_ID) AS RowNo, 
                       CO.*, 
                       ISNULL(C.Country_Name, '') AS Country_Name, 
                       (CASE CardOwner_Gender
                            WHEN 0
                            THEN 'Male'
                            ELSE 'Female'
                        END) AS CardOwner_GenderText, 
                       ISNULL(PL.PlayerLevel_Name, '') AS PlayerLevel_Name, 
                       DATEDIFF(Y, YEAR(ISNULL(CardOwner_DOB, GETDATE())), YEAR(GETDATE())) AS PlayerAge, 
                       (CASE CardOwner_Status
                            WHEN 00
                            THEN 'Active'
                            ELSE 'Inactive'
                        END) AS CardOwner_StatusText, 
                       ISNULL(
                (
                    SELECT SUM(Card_PointAccumulate)
                    FROM tblCard
                    WHERE Card_CardOwner_ID = CO.CardOwner_ID
                ), 0) AS AccumulatePoint
                FROM tblCardOwner CO(NOLOCK)
                     LEFT OUTER JOIN tblCountry C ON C.Country_ID = CO.CardOwner_Country_ID
                     INNER JOIN tblPlayerLevel PL ON PL.PlayerLevel_ID = CO.CardOwner_Level
                WHERE CardOwner_Name LIKE '%' + @strName + '%'
                      AND CardOwner_IC LIKE '%' + @strIDNumber + '%'
                      AND (CASE
                               WHEN @intGender = -1
                               THEN 1
                               ELSE CASE
                                        WHEN CardOwner_Gender = @intGender
                                        THEN 1
                                        ELSE 0
                                    END
                           END) > 0
                      AND (CASE
                               WHEN @intCountry = -1
                               THEN 1
                               ELSE CASE
                                        WHEN CardOwner_Country_ID = @intCountry
                                        THEN 1
                                        ELSE 0
                                    END
                           END) > 0
                      AND (CASE
                               WHEN @intLevel = -1
                               THEN 1
                               ELSE CASE
                                        WHEN CardOwner_Level = @intLevel
                                        THEN 1
                                        ELSE 0
                                    END
                           END) > 0
                      AND (DATEDIFF(Y, YEAR(ISNULL(CardOwner_DOB, GETDATE())), YEAR(GETDATE())) BETWEEN @intAgeFrom AND @intAgeTo)
                      AND CO.CardOwner_ID IN
                (
                    SELECT Card_CardOwner_ID
                    FROM tblCard
                    WHERE Card_SerialNo LIKE '%' + @strCardNumber + '%'
                          AND Card_Status = 0
                )
                      AND (CASE
                               WHEN @intPlayerID = -1
                               THEN 1
                               ELSE CASE
                                        WHEN CardOwner_ID = @intPlayerID
                                        THEN 1
                                        ELSE 0
                                    END
                           END) > 0
                ORDER BY LEN(CardOwner_Name), 
                         CardOwner_Name;
            END;
        IF @intPlayerID <> -1
            BEGIN
                SELECT C.*, 
                       CT.CardType_Name, 
                       (CASE Card_Status
                            WHEN 0
                            THEN 'Active'
                            ELSE 'Inactive'
                        END) AS Card_StatusText
                FROM tblCard C(NOLOCK)
                     INNER JOIN tblCardType CT ON C.Card_Type = CT.CardType_ID
                WHERE C.Card_CardOwner_ID = @intPlayerID
                      AND C.Card_Status = 0;
            END;
    END;

	--new changes ok
