/****** Object:  Table [dbo].[CloudSync]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CloudSync](
	[SyncId] [int] IDENTITY(1,1) NOT NULL,
	[EntityName] [varchar](50) NOT NULL,
	[EntityId] [int] NOT NULL,
	[Operation] [varchar](10) NOT NULL,
	[SyncStatus] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SyncId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
