/****** Object:  Table [dbo].[tblCard_Voucher]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCard_Voucher](
	[CardVoucher_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CardVoucher_GenerateDate] [datetime] NULL,
	[CardVoucher_Number] [nvarchar](50) NULL,
	[CardVoucher_Value] [money] NOT NULL,
	[CardVoucher_Type] [smallint] NOT NULL,
	[CardVoucher_Status] [smallint] NOT NULL,
	[CardVoucher_Expired] [datetime] NULL,
	[CardVoucher_CardOwner_ID] [bigint] NOT NULL,
	[CardVoucher_Card_ID] [bigint] NOT NULL,
	[CardVoucher_CreatedBy] [nvarchar](50) NULL,
	[CardVoucher_CreatedDate] [datetime] NULL,
	[CardVoucher_RedeemBy] [nvarchar](50) NULL,
	[CardVoucher_RedeemDate] [datetime] NULL,
 CONSTRAINT [PK_tblCard_Voucher] PRIMARY KEY CLUSTERED 
(
	[CardVoucher_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblCard_Voucher] ADD  CONSTRAINT [DF_tblCard_Voucher_CardVoucher_Value]  DEFAULT ((0)) FOR [CardVoucher_Value]
ALTER TABLE [dbo].[tblCard_Voucher] ADD  CONSTRAINT [DF_tblCard_Voucher_CardVoucher_Type]  DEFAULT ((0)) FOR [CardVoucher_Type]
ALTER TABLE [dbo].[tblCard_Voucher] ADD  CONSTRAINT [DF_tblCard_Voucher_CardVoucher_Status]  DEFAULT ((0)) FOR [CardVoucher_Status]
ALTER TABLE [dbo].[tblCard_Voucher] ADD  CONSTRAINT [DF_tblCard_Voucher_CardVoucher_CardOwner_ID]  DEFAULT ((0)) FOR [CardVoucher_CardOwner_ID]
ALTER TABLE [dbo].[tblCard_Voucher] ADD  CONSTRAINT [DF_tblCard_Voucher_CardVoucher_Card_ID]  DEFAULT ((0)) FOR [CardVoucher_Card_ID]
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0: New, 1: Used, 2: Expired' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCard_Voucher', @level2type=N'COLUMN',@level2name=N'CardVoucher_Status'
