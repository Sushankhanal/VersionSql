/****** Object:  Table [dbo].[tblWalletTransType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblWalletTransType](
	[WTransType_ID] [int] NOT NULL,
	[WTransType_Name] [nvarchar](50) NULL,
	[WTransType_Sign] [smallint] NULL,
	[WTransType_DefaultPointRate] [money] NOT NULL,
	[WTransType_PointRateConvertion] [money] NOT NULL,
	[WTransType_AllowEdit] [int] NOT NULL,
	[WTransType_AllowDisplayAtReport] [smallint] NOT NULL,
 CONSTRAINT [PK_tblWalletTransType] PRIMARY KEY CLUSTERED 
(
	[WTransType_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblWalletTransType] ADD  CONSTRAINT [DF_tblWalletTransType_WTransType_DefaultPointRate]  DEFAULT ((0)) FOR [WTransType_DefaultPointRate]
ALTER TABLE [dbo].[tblWalletTransType] ADD  CONSTRAINT [DF_tblWalletTransType_WTransType_PointRateConvertion]  DEFAULT ((-100)) FOR [WTransType_PointRateConvertion]
ALTER TABLE [dbo].[tblWalletTransType] ADD  CONSTRAINT [DF_tblWalletTransType_WTransType_AllowEdit]  DEFAULT ((0)) FOR [WTransType_AllowEdit]
ALTER TABLE [dbo].[tblWalletTransType] ADD  CONSTRAINT [DF_tblWalletTransType_WTransType_AllowDisplayAtReport]  DEFAULT ((0)) FOR [WTransType_AllowDisplayAtReport]
