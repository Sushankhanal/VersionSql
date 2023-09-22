/****** Object:  Table [dbo].[tblTableStatus]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblTableStatus](
	[TableStatus_ID] [int] NOT NULL,
	[TableStatus_Name] [nvarchar](50) NULL,
	[TableStatus_ChiName] [nvarchar](50) NULL,
	[TableStatus_Color] [nvarchar](50) NULL,
	[TableStatus_ColorCode] [nvarchar](50) NULL,
 CONSTRAINT [PK_tblTableStatus] PRIMARY KEY CLUSTERED 
(
	[TableStatus_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblTableStatus] ADD  CONSTRAINT [DF_tblTableStatus_TableStatus_ColorCode]  DEFAULT ('') FOR [TableStatus_ColorCode]
