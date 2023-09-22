/****** Object:  Table [dbo].[CloudConfig]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CloudConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SiteId] [int] NULL,
	[SiteName] [nvarchar](50) NULL,
	[Configed] [bit] NULL,
 CONSTRAINT [PK_CloudConfig] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
