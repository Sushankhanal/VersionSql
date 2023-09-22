/****** Object:  Table [dbo].[tblWalletType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblWalletType](
	[WalletType_ID] [int] NOT NULL,
	[WalletType_Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_tblWalletType] PRIMARY KEY CLUSTERED 
(
	[WalletType_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
