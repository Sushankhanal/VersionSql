/****** Object:  Procedure [dbo].[Cloud_CreateLinkedRemoteServer]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Cloud_CreateLinkedRemoteServer]
    @datasrc NVARCHAR(128),
    @RemoteServerName NVARCHAR(128), -- the name of the remote server to link
    @RemoteUserID NVARCHAR(128), -- the user ID for the remote server
    @RemotePassword NVARCHAR(128), -- the password for the remote server
    @strcatelog NVARCHAR(50) -- the name of the remote database to link
AS
BEGIN
    DECLARE @provstr NVARCHAR(4000)
    --SET @provstr = 'Data Source=' + @RemoteServerName + ';User ID=' + @RemoteUserID + ';Password=' + @RemotePassword + ';Initial Catalog=' + @RemoteDatabaseName + ';'

    -- First, check if the remote server is already linked
    IF NOT EXISTS(SELECT * FROM sys.servers WHERE name = @RemoteServerName)
    BEGIN
        -- If not, create the linked server
        EXEC sp_addlinkedserver
            @server = @RemoteServerName,
            @srvproduct = '',
            @provider = 'SQLOLEDB',
            @datasrc = @datasrc,
            @location = '',
           @provstr = '',
            @catalog=@strcatelog;
    END
    ELSE
    BEGIN
        -- If it is already linked, update the provider string to ensure it's up-to-date
        EXEC sp_dropserver @RemoteServerName, 'droplogins'
        EXEC sp_addlinkedserver
            @server = @RemoteServerName,
            @srvproduct = '',
            @provider = 'SQLOLEDB',
            @datasrc = @datasrc,
            @location = '',
            @provstr = N'',
            @catalog=@strcatelog;
    END
    EXEC sp_addlinkedsrvlogin
  @rmtsrvname = @RemoteServerName,
  @useself = 'false',
  @rmtuser = @RemoteUserID,
  @rmtpassword = @RemotePassword;
    EXEC sp_serveroption @RemoteServerName, 'rpc out', true;
END
