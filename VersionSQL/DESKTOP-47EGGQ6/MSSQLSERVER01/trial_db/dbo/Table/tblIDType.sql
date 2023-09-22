/****** Object:  Table [dbo].[tblIDType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblIDType](
	[IDType_ID] [bigint] NOT NULL,
	[IDType_Name] [nvarchar](50) NULL,
	[IDType_Status] [smallint] NOT NULL,
	[IDType_Sort] [int] NOT NULL,
 CONSTRAINT [PK_tblIDType] PRIMARY KEY CLUSTERED 
(
	[IDType_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblIDType] ADD  CONSTRAINT [DF_tblIDType_IDType_Status]  DEFAULT ((0)) FOR [IDType_Status]
ALTER TABLE [dbo].[tblIDType] ADD  CONSTRAINT [DF_tblIDType_IDType_Sort]  DEFAULT ((0)) FOR [IDType_Sort]
