/****** Object:  Table [dbo].[tblWalletTrans]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblWalletTrans](
	[WalletTrans_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[WalletTrans_Code] [nvarchar](50) NULL,
	[WalletTrans_UserCode] [nvarchar](50) NULL,
	[WalletTrans_WalletCode] [nvarchar](50) NULL,
	[WalletTrans_Type] [int] NULL,
	[WalletTrans_Value] [money] NULL,
	[WalletTrans_MoneyValue] [money] NULL,
	[WalletTrans_RefCode] [nvarchar](50) NULL,
	[WalletTrans_Remarks] [nvarchar](max) NULL,
	[WalletTrans_CreatedBy] [nvarchar](50) NULL,
	[WalletTrans_CreatedDate] [datetime] NULL,
	[WalletTrans_CampaignCode] [nvarchar](50) NULL,
	[WalletTrans_PaymentMode] [int] NOT NULL,
	[WalletTrans_QRCodeText] [nvarchar](max) NULL,
	[WalletTrans_Timespan] [nvarchar](50) NULL,
 CONSTRAINT [PK_tblWalletTrans] PRIMARY KEY CLUSTERED 
(
	[WalletTrans_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[tblWalletTrans] ADD  CONSTRAINT [DF_tblWalletTrans_WalletTrans_PaymentMode]  DEFAULT ((0)) FOR [WalletTrans_PaymentMode]
