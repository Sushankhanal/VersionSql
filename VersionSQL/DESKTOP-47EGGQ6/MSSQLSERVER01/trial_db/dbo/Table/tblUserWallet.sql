/****** Object:  Table [dbo].[tblUserWallet]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblUserWallet](
	[UWallet_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UWallet_UserCode] [nvarchar](50) NULL,
	[UWallet_Code] [nvarchar](50) NULL,
	[UWallet_Type] [smallint] NULL,
	[UWallet_Balance] [money] NULL,
	[UWallet_ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_tblUser_Wallet] PRIMARY KEY CLUSTERED 
(
	[UWallet_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
