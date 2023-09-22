/****** Object:  Table [dbo].[session_transaction]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[session_transaction](
	[card_serialNo] [nvarchar](100) NOT NULL,
	[session_id] [bigint] NULL,
 CONSTRAINT [PK_session_transaction] PRIMARY KEY CLUSTERED 
(
	[card_serialNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
