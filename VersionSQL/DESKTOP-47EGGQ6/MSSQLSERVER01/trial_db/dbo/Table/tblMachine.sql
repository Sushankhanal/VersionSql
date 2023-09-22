/****** Object:  Table [dbo].[tblMachine]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblMachine](
	[Machine_ID] [bigint] NOT NULL,
	[Machine_Name] [nvarchar](50) NULL,
	[Base_ID] [bigint] NULL,
	[Bank_ID] [bigint] NULL,
	[Zone_ID] [bigint] NULL,
	[Floor_ID] [bigint] NULL,
	[Game_ID] [bigint] NULL,
	[Model_ID] [bigint] NULL,
 CONSTRAINT [PK_tblMachine] PRIMARY KEY CLUSTERED 
(
	[Machine_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
