/****** Object:  Table [dbo].[tblWalletTransTemp]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblWalletTransTemp](
	[WalletTrans_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[WalletTrans_Code] [nvarchar](50) NULL,
	[WalletTrans_UserCode] [nvarchar](50) NULL,
	[WalletTrans_CreateDate] [datetime] NULL,
	[WalletTrans_Status] [smallint] NULL,
 CONSTRAINT [PK_tblWalletTransTemp] PRIMARY KEY CLUSTERED 
(
	[WalletTrans_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
