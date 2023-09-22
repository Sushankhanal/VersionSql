/****** Object:  Table [dbo].[tblOrderAccess]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblOrderAccess](
	[OrderAccess_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[OrderAccess_UserCode] [nvarchar](50) NULL,
	[OrderAccess_Type] [smallint] NULL,
	[OrderAccess_CreateDate] [datetime] NULL,
 CONSTRAINT [PK_tblOrderAccess] PRIMARY KEY CLUSTERED 
(
	[OrderAccess_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
