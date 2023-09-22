/****** Object:  Table [dbo].[tblProductCounter]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblProductCounter](
	[ProductCounter_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductCounter_CounterID] [bigint] NULL,
	[ProductCounter_ProductCode] [nvarchar](50) NULL,
 CONSTRAINT [PK_tblProductCounter] PRIMARY KEY CLUSTERED 
(
	[ProductCounter_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
