/****** Object:  Table [dbo].[tblPointTrans]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblPointTrans](
	[PointTrans_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PointTrans_Code] [nvarchar](50) NULL,
	[PointTrans_UserCode] [nvarchar](50) NULL,
	[PointTrans_Type] [int] NULL,
	[PointTrans_Value] [money] NULL,
	[PointTrans_PointValue] [money] NULL,
	[PointTrans_RefCode] [nvarchar](50) NULL,
	[PointTrans_Remarks] [nvarchar](max) NULL,
	[PointTrans_CreatedBy] [nvarchar](50) NULL,
	[PointTrans_CreatedDate] [datetime] NULL,
	[PointTrans_CampaignCode] [nvarchar](50) NULL,
	[PointTrans_QRCodeText] [nvarchar](max) NULL,
	[PointTrans_WalletAmt] [money] NULL,
	[PointTrans_Ratio] [money] NULL,
	[PointTrans_LocalTransID] [int] NOT NULL,
	[PointTrans_BranchID] [int] NOT NULL,
	[PointTrans_MachineID] [int] NOT NULL,
 CONSTRAINT [PK_tblPointTrans] PRIMARY KEY CLUSTERED 
(
	[PointTrans_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[tblPointTrans] ADD  CONSTRAINT [DF_tblPointTrans_PointTrans_LocalTransID]  DEFAULT ((0)) FOR [PointTrans_LocalTransID]
ALTER TABLE [dbo].[tblPointTrans] ADD  CONSTRAINT [DF_tblPointTrans_PointTrans_BranchID]  DEFAULT ((0)) FOR [PointTrans_BranchID]
ALTER TABLE [dbo].[tblPointTrans] ADD  CONSTRAINT [DF_tblPointTrans_PointTrans_MachineID]  DEFAULT ((0)) FOR [PointTrans_MachineID]
