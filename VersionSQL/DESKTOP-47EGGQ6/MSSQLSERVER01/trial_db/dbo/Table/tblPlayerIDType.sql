/****** Object:  Table [dbo].[tblPlayerIDType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblPlayerIDType](
	[PlayerIDType_ID] [int] NOT NULL,
	[PlayerIDType_Name] [nvarchar](50) NULL,
	[PlayerIDType_Sort] [int] NOT NULL,
 CONSTRAINT [PK_tblPlayerIDType] PRIMARY KEY CLUSTERED 
(
	[PlayerIDType_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblPlayerIDType] ADD  CONSTRAINT [DF_tblPlayerIDType_PlayerIDType_Sort]  DEFAULT ((0)) FOR [PlayerIDType_Sort]
