/****** Object:  Table [dbo].[tblCalling]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCalling](
	[Calling_ID] [int] NOT NULL,
	[Calling_Name] [nvarchar](50) NULL,
	[Calling_ColorName] [nchar](10) NULL,
	[Calling_ColorCode] [nvarchar](50) NULL,
 CONSTRAINT [PK_tblCalling] PRIMARY KEY CLUSTERED 
(
	[Calling_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
