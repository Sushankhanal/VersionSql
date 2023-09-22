/****** Object:  Table [dbo].[tblUser_GroupDetail]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblUser_GroupDetail](
	[UGroupD_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UGroupD_GroupID] [bigint] NULL,
	[UGroupD_MenuID] [bigint] NULL,
 CONSTRAINT [PK_tblUser_GroupDetail] PRIMARY KEY CLUSTERED 
(
	[UGroupD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
